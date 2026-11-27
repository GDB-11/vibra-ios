import Domain
import Foundation
import Observation

/// Único reproductor de la app. Vive fuera de las vistas y de los ViewModels.
///
/// Pide la URL a `StreamingRepository`, así que no sabe de dónde sale el audio.
/// Nunca registra URLs firmadas.
@Observable
@MainActor
public final class PlaybackService: PlaybackControlling {
    private static let previewDurationSeconds = 30

    public private(set) var nowPlaying: NowPlaying?

    @ObservationIgnored private let streaming: any StreamingRepository
    @ObservationIgnored private let engine: any AudioEngine
    @ObservationIgnored private let session: any AudioSessionControlling
    @ObservationIgnored private let publisher: any NowPlayingPublishing
    @ObservationIgnored private let remoteCommands: any RemoteCommandHandling

    /// Carga en curso. Es visible en el módulo para que las pruebas puedan esperarla.
    @ObservationIgnored private(set) var loadTask: Task<Void, Never>?
    /// Intención del usuario; se respeta aunque la URL todavía no haya llegado.
    @ObservationIgnored private var wantsToPlay = false
    @ObservationIgnored private var isLoaded = false
    @ObservationIgnored private var hasFinished = false
    @ObservationIgnored private var hasFailed = false
    @ObservationIgnored private var resumesAfterInterruption = false

    public convenience init(streaming: any StreamingRepository) {
        self.init(
            streaming: streaming,
            engine: AVPlayerAudioEngine(),
            session: SystemAudioSessionController(),
            publisher: SystemNowPlayingPublisher(),
            remoteCommands: SystemRemoteCommandController()
        )
    }

    init(
        streaming: any StreamingRepository,
        engine: any AudioEngine,
        session: any AudioSessionControlling,
        publisher: any NowPlayingPublishing,
        remoteCommands: any RemoteCommandHandling
    ) {
        self.streaming = streaming
        self.engine = engine
        self.session = session
        self.publisher = publisher
        self.remoteCommands = remoteCommands

        engine.onEvent = { [weak self] in self?.handle($0) }
        session.onEvent = { [weak self] in self?.handle($0) }
        remoteCommands.onCommand = { [weak self] in self?.handle($0) }
    }

    // MARK: - Intenciones

    public func play(_ track: Track, isPreview: Bool) {
        loadTask?.cancel()
        engine.reset()
        isLoaded = false
        hasFinished = false
        hasFailed = false
        resumesAfterInterruption = false
        wantsToPlay = true
        nowPlaying = NowPlaying(
            track: track,
            elapsedSeconds: 0,
            durationSeconds: isPreview ? Self.previewDurationSeconds : track.durationSeconds,
            isPlaying: true,
            isPreview: isPreview
        )

        loadTask = Task { [weak self, streaming = self.streaming] in
            let access = try? await streaming.streamAccess(trackID: track.id)
            // Otra pista o `stop()` dejan sin efecto una respuesta tardía.
            guard !Task.isCancelled else { return }
            self?.finishLoading(access, track: track, isPreview: isPreview)
        }
    }

    public func togglePlayPause() {
        if wantsToPlay {
            pause()
        } else {
            resume()
        }
    }

    /// Sin efecto hasta que exista la cola de reproducción.
    public func skipToNext() {}

    /// Sin efecto hasta que exista la cola de reproducción.
    public func skipToPrevious() {}

    public func stop() {
        loadTask?.cancel()
        loadTask = nil
        wantsToPlay = false
        isLoaded = false
        hasFinished = false
        hasFailed = false
        resumesAfterInterruption = false
        engine.reset()
        nowPlaying = nil
        publisher.clear()
        remoteCommands.disable()
        session.deactivate()
    }

    // MARK: - Carga y estado

    private func finishLoading(_ access: StreamAccess?, track: Track, isPreview: Bool) {
        let url: URL
        let playsPreview: Bool

        switch access {
        case .granted(let fullURL):
            // Si ya hay derechos, se reproduce la pista completa aunque se pidiera la vista previa.
            url = fullURL
            playsPreview = false
        case .locked(let previewURL) where isPreview:
            url = previewURL
            playsPreview = true
        case .locked, nil:
            // Falta mostrar el error y el muro de pago al conectar la selección (VIBR2-1092).
            stop()
            return
        }

        if playsPreview != isPreview {
            nowPlaying = NowPlaying(
                track: track,
                elapsedSeconds: 0,
                durationSeconds: track.durationSeconds,
                isPlaying: wantsToPlay,
                isPreview: playsPreview
            )
        }

        do {
            try session.activate()
        } catch {
            stop()
            return
        }

        engine.load(url)
        isLoaded = true
        remoteCommands.enable()
        if wantsToPlay {
            engine.play()
        }
        publish()
    }

    private func pause() {
        guard nowPlaying != nil else { return }
        wantsToPlay = false
        resumesAfterInterruption = false
        engine.pause()
        update(isPlaying: false)
        publish()
    }

    private func resume() {
        guard let current = nowPlaying else { return }

        // Un elemento fallido no se puede reanudar: se vuelve a pedir la URL desde el principio.
        if hasFailed {
            play(current.track, isPreview: current.isPreview)
            return
        }

        if isLoaded {
            do {
                // Tras una interrupción hay que activar la sesión otra vez.
                try session.activate()
            } catch {
                return
            }
        }

        wantsToPlay = true
        resumesAfterInterruption = false

        if hasFinished {
            hasFinished = false
            engine.seek(to: 0)
            update(elapsedSeconds: 0)
        }
        if isLoaded {
            engine.play()
        }
        update(isPlaying: true)
        publish()
    }

    private func seek(to seconds: Double) {
        guard isLoaded, let current = nowPlaying, seconds.isFinite else { return }
        let target = min(max(seconds, 0), Double(current.durationSeconds))
        hasFinished = false
        engine.seek(to: target)
        update(elapsedSeconds: Int(target))
        publish()
    }

    // MARK: - Eventos

    private func handle(_ event: AudioEngineEvent) {
        guard isLoaded, let current = nowPlaying else { return }

        switch event {
        case .elapsed(let seconds):
            guard seconds.isFinite else { return }
            update(elapsedSeconds: min(max(Int(seconds), 0), current.durationSeconds))
        case .duration(let seconds):
            guard seconds.isFinite, seconds > 0 else { return }
            let duration = Int(seconds.rounded())
            guard duration != current.durationSeconds else { return }
            update(durationSeconds: duration)
            publish()
        case .finished:
            wantsToPlay = false
            hasFinished = true
            engine.pause()
            update(elapsedSeconds: current.durationSeconds, isPlaying: false)
            publish()
        case .failed:
            wantsToPlay = false
            isLoaded = false
            hasFailed = true
            resumesAfterInterruption = false
            engine.reset()
            update(isPlaying: false)
            publish()
        }
    }

    private func handle(_ event: AudioSessionEvent) {
        guard nowPlaying != nil else { return }

        switch event {
        case .interruptionBegan:
            let shouldRemember = wantsToPlay || resumesAfterInterruption
            pause()
            resumesAfterInterruption = shouldRemember
        case .interruptionEnded(let shouldResume):
            let wasPlaying = resumesAfterInterruption
            resumesAfterInterruption = false
            if shouldResume, wasPlaying {
                resume()
            }
        case .outputDeviceRemoved:
            // Nunca se reanuda solo: el audio no debe salir de golpe por el altavoz.
            pause()
        }
    }

    private func handle(_ command: RemoteCommand) {
        switch command {
        case .play: resume()
        case .pause: pause()
        case .togglePlayPause: togglePlayPause()
        case .seek(let seconds): seek(to: seconds)
        }
    }

    // MARK: - Publicación

    /// Solo asigna si algo cambia, para no invalidar las vistas sin motivo.
    private func update(elapsedSeconds: Int? = nil, durationSeconds: Int? = nil, isPlaying: Bool? = nil) {
        guard let current = nowPlaying else { return }
        let updated = NowPlaying(
            track: current.track,
            elapsedSeconds: elapsedSeconds ?? current.elapsedSeconds,
            durationSeconds: durationSeconds ?? current.durationSeconds,
            isPlaying: isPlaying ?? current.isPlaying,
            isPreview: current.isPreview
        )
        if updated != current {
            nowPlaying = updated
        }
    }

    private func publish() {
        // Antes de tener audio no se muestra nada en la pantalla de bloqueo.
        guard let nowPlaying, isLoaded || hasFailed else { return }
        publisher.publish(nowPlaying)
    }
}
