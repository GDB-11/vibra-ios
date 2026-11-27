import AVFoundation

enum AudioEngineEvent: Equatable, Sendable {
    case elapsed(seconds: Double)
    case duration(seconds: Double)
    case finished
    case failed
}

/// Motor de audio que usa `PlaybackService`. Permite sustituir `AVPlayer` en las pruebas.
@MainActor
protocol AudioEngine: AnyObject {
    var onEvent: (@MainActor (AudioEngineEvent) -> Void)? { get set }

    func load(_ url: URL)
    func play()
    func pause()
    func seek(to seconds: Double)
    func reset()
}

/// Envoltorio de `AVPlayer`. Nunca registra la URL ni errores que puedan incluirla.
@MainActor
final class AVPlayerAudioEngine: AudioEngine {
    var onEvent: (@MainActor (AudioEngineEvent) -> Void)?

    private let player = AVPlayer()
    private var monitor: Task<Void, Never>?
    private var endObserver: Task<Void, Never>?
    private var failureObserver: Task<Void, Never>?

    init() {
        // Cada notificación se reduce a un identificador `Sendable` antes de llegar al actor principal.
        endObserver = Task { [weak self] in
            let items = NotificationCenter.default
                .notifications(named: AVPlayerItem.didPlayToEndTimeNotification)
                .compactMap { notification in notification.object.map { ObjectIdentifier($0 as AnyObject) } }
            for await item in items {
                self?.report(.finished, from: item)
            }
        }
        failureObserver = Task { [weak self] in
            let items = NotificationCenter.default
                .notifications(named: AVPlayerItem.failedToPlayToEndTimeNotification)
                .compactMap { notification in notification.object.map { ObjectIdentifier($0 as AnyObject) } }
            for await item in items {
                self?.report(.failed, from: item)
            }
        }
    }

    func load(_ url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        startMonitor()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func seek(to seconds: Double) {
        player.seek(
            to: CMTime(seconds: seconds, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    func reset() {
        monitor?.cancel()
        monitor = nil
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    /// Ignora los avisos de elementos que ya no son el actual.
    private func report(_ event: AudioEngineEvent, from item: ObjectIdentifier) {
        guard let current = player.currentItem, ObjectIdentifier(current) == item else { return }
        onEvent?(event)
    }

    /// Se consulta el estado periódicamente en lugar de usar observadores que pueden ejecutarse
    /// fuera del actor principal.
    private func startMonitor() {
        monitor?.cancel()
        monitor = Task { [weak self] in
            while !Task.isCancelled {
                self?.refresh()
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    private func refresh() {
        guard let item = player.currentItem else { return }

        if item.status == .failed {
            monitor?.cancel()
            onEvent?(.failed)
            return
        }
        // Hasta que el elemento está listo, la duración y la posición no son fiables.
        guard item.status == .readyToPlay else { return }

        let duration = item.duration.seconds
        if duration.isFinite, duration > 0 {
            onEvent?(.duration(seconds: duration))
        }
        // El evento anterior puede haber cambiado el elemento.
        guard player.currentItem === item else { return }

        let elapsed = player.currentTime().seconds
        if elapsed.isFinite {
            onEvent?(.elapsed(seconds: elapsed))
        }
    }
}
