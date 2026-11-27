import AVFoundation
import Domain
import MediaPlayer
import Testing

@testable import Playback

@MainActor
struct PlaybackServiceTests {
    private let engine = FakeAudioEngine()
    private let session = FakeAudioSession()
    private let publisher = FakeNowPlayingPublisher()
    private let remoteCommands = FakeRemoteCommands()
    private let fullURL = URL(fileURLWithPath: "/pista.flac")
    private let previewURL = URL(fileURLWithPath: "/previa.m4a")

    private func makeService(_ streaming: any StreamingRepository) -> PlaybackService {
        PlaybackService(
            streaming: streaming,
            engine: engine,
            session: session,
            publisher: publisher,
            remoteCommands: remoteCommands
        )
    }

    private func makePlayingService() async throws -> PlaybackService {
        let service = makeService(FakeStreaming(access: .granted(url: fullURL)))
        service.play(try #require(SampleData.tracks.first), isPreview: false)
        await service.loadTask?.value
        return service
    }

    // MARK: - Carga

    @Test func reproduceLaPistaConAcceso() async throws {
        let service = try await makePlayingService()

        #expect(engine.loadedURLs == [fullURL])
        #expect(engine.isPlaying)
        #expect(session.activations == 1)
        #expect(remoteCommands.isEnabled)
        #expect(service.nowPlaying?.isPlaying == true)
        #expect(publisher.published.last == service.nowPlaying)
    }

    @Test func laVistaPreviaUsaSuURL() async throws {
        let service = makeService(FakeStreaming(access: .locked(previewURL: previewURL)))

        service.play(try #require(SampleData.tracks.first), isPreview: true)
        await service.loadTask?.value

        #expect(engine.loadedURLs == [previewURL])
        #expect(service.nowPlaying?.isPreview == true)
        #expect(service.nowPlaying?.durationSeconds == 30)
    }

    @Test func conAccesoLaVistaPreviaPasaAPistaCompleta() async throws {
        let service = makeService(FakeStreaming(access: .granted(url: fullURL)))
        let track = try #require(SampleData.tracks.first)

        service.play(track, isPreview: true)
        await service.loadTask?.value

        #expect(service.nowPlaying?.isPreview == false)
        #expect(service.nowPlaying?.durationSeconds == track.durationSeconds)
    }

    @Test func unaPistaBloqueadaNoSeReproduceCompleta() async throws {
        let service = makeService(FakeStreaming(access: .locked(previewURL: previewURL)))

        service.play(try #require(SampleData.tracks.first), isPreview: false)
        await service.loadTask?.value

        #expect(engine.loadedURLs.isEmpty)
        #expect(service.nowPlaying == nil)
    }

    @Test func siFallaLaPeticionNoQuedaNadaEnReproduccion() async throws {
        let service = makeService(FakeStreaming(access: nil))

        service.play(try #require(SampleData.tracks.first), isPreview: false)
        await service.loadTask?.value

        #expect(service.nowPlaying == nil)
        #expect(publisher.published.isEmpty)
    }

    @Test func unaRespuestaTardiaSeIgnora() async throws {
        let streaming = GatedStreaming()
        let service = makeService(streaming)
        let first = try #require(SampleData.tracks.first)
        let second = try #require(SampleData.tracks.dropFirst().first)
        let secondURL = URL(fileURLWithPath: "/segunda.flac")

        service.play(first, isPreview: false)
        let firstLoad = service.loadTask
        await streaming.waitForRequest(trackID: first.id)
        service.play(second, isPreview: false)
        await streaming.waitForRequest(trackID: second.id)

        await streaming.resolve(trackID: second.id, with: .granted(url: secondURL))
        await service.loadTask?.value
        await streaming.resolve(trackID: first.id, with: .granted(url: fullURL))
        await firstLoad?.value

        #expect(engine.loadedURLs == [secondURL])
        #expect(service.nowPlaying?.track == second)
    }

    @Test func pausarDuranteLaCargaSeRespeta() async throws {
        let streaming = GatedStreaming()
        let service = makeService(streaming)
        let track = try #require(SampleData.tracks.first)

        service.play(track, isPreview: false)
        await streaming.waitForRequest(trackID: track.id)
        service.togglePlayPause()
        await streaming.resolve(trackID: track.id, with: .granted(url: fullURL))
        await service.loadTask?.value

        #expect(!engine.isPlaying)
        #expect(service.nowPlaying?.isPlaying == false)
    }

    // MARK: - Motor

    @Test func elAvanceNoRepublicaEnLaPantallaDeBloqueo() async throws {
        let service = try await makePlayingService()
        let publications = publisher.published.count

        engine.onEvent?(.elapsed(seconds: 12.7))

        #expect(service.nowPlaying?.elapsedSeconds == 12)
        #expect(publisher.published.count == publications)
    }

    @Test func laDuracionRealSustituyeALaDelCatalogo() async throws {
        let service = try await makePlayingService()

        engine.onEvent?(.duration(seconds: 200.4))

        #expect(service.nowPlaying?.durationSeconds == 200)
        #expect(publisher.published.last?.durationSeconds == 200)
    }

    @Test func alTerminarSePuedeVolverAEmpezar() async throws {
        let service = try await makePlayingService()

        engine.onEvent?(.finished)
        #expect(service.nowPlaying?.isPlaying == false)
        service.togglePlayPause()

        #expect(engine.seeks == [0])
        #expect(engine.isPlaying)
        #expect(service.nowPlaying?.elapsedSeconds == 0)
    }

    @Test func trasUnFalloReproducirVuelveAPedirLaURL() async throws {
        let service = try await makePlayingService()

        engine.onEvent?(.failed)
        #expect(service.nowPlaying?.isPlaying == false)
        service.togglePlayPause()
        await service.loadTask?.value

        #expect(engine.loadedURLs == [fullURL, fullURL])
        #expect(engine.isPlaying)
    }

    // MARK: - Interrupciones y rutas

    @Test func trasUnaInterrupcionSeReanudaSiElSistemaLoPide() async throws {
        let service = try await makePlayingService()

        session.onEvent?(.interruptionBegan)
        #expect(!engine.isPlaying)
        session.onEvent?(.interruptionEnded(shouldResume: true))

        #expect(engine.isPlaying)
        #expect(service.nowPlaying?.isPlaying == true)
        #expect(session.activations == 2)
    }

    @Test func sinPermisoDelSistemaNoSeReanuda() async throws {
        let service = try await makePlayingService()

        session.onEvent?(.interruptionBegan)
        session.onEvent?(.interruptionEnded(shouldResume: false))

        #expect(!engine.isPlaying)
        #expect(service.nowPlaying?.isPlaying == false)
    }

    @Test func siYaEstabaEnPausaNoSeReanuda() async throws {
        let service = try await makePlayingService()
        service.togglePlayPause()

        session.onEvent?(.interruptionBegan)
        session.onEvent?(.interruptionEnded(shouldResume: true))

        #expect(!engine.isPlaying)
    }

    @Test func unaPausaDelUsuarioDuranteLaInterrupcionSeRespeta() async throws {
        let service = try await makePlayingService()

        session.onEvent?(.interruptionBegan)
        remoteCommands.onCommand?(.pause)
        session.onEvent?(.interruptionEnded(shouldResume: true))

        #expect(!engine.isPlaying)
        #expect(service.nowPlaying?.isPlaying == false)
    }

    @Test func alDesconectarLosAuricularesSePausa() async throws {
        let service = try await makePlayingService()

        session.onEvent?(.outputDeviceRemoved)

        #expect(!engine.isPlaying)
        #expect(service.nowPlaying?.isPlaying == false)
        #expect(publisher.published.last?.isPlaying == false)
    }

    @Test func lasNotificacionesDelSistemaSeTraducen() {
        let began: [AnyHashable: Any] = [
            AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue
        ]
        let ended: [AnyHashable: Any] = [
            AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue,
            AVAudioSessionInterruptionOptionKey: AVAudioSession.InterruptionOptions.shouldResume.rawValue
        ]
        let removed: [AnyHashable: Any] = [
            AVAudioSessionRouteChangeReasonKey: AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
        ]
        let added: [AnyHashable: Any] = [
            AVAudioSessionRouteChangeReasonKey: AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
        ]

        #expect(AudioSessionEvent(interruption: began) == .interruptionBegan)
        #expect(AudioSessionEvent(interruption: ended) == .interruptionEnded(shouldResume: true))
        #expect(AudioSessionEvent(routeChange: removed) == .outputDeviceRemoved)
        #expect(AudioSessionEvent(routeChange: added) == nil)
    }

    // MARK: - Comandos remotos y Now Playing

    @Test func losComandosRemotosControlanLaPista() async throws {
        let service = try await makePlayingService()

        remoteCommands.onCommand?(.pause)
        #expect(!engine.isPlaying)
        remoteCommands.onCommand?(.play)
        #expect(engine.isPlaying)
        remoteCommands.onCommand?(.togglePlayPause)
        #expect(!engine.isPlaying)
        remoteCommands.onCommand?(.seek(seconds: 45))

        #expect(engine.seeks == [45])
        #expect(service.nowPlaying?.elapsedSeconds == 45)
        #expect(publisher.published.last?.elapsedSeconds == 45)
    }

    @Test func elSaltoRemotoNoSaleDeLaPista() async throws {
        let service = try await makePlayingService()
        let duration = try #require(service.nowPlaying?.durationSeconds)

        remoteCommands.onCommand?(.seek(seconds: 100_000))

        #expect(engine.seeks == [Double(duration)])
    }

    @Test func laPantallaDeBloqueoRecibeLosDatosDeLaPista() throws {
        let track = try #require(SampleData.tracks.first)
        let nowPlaying = NowPlaying(
            track: track,
            elapsedSeconds: 10,
            durationSeconds: 200,
            isPlaying: false,
            isPreview: false
        )

        let info = SystemNowPlayingPublisher.info(for: nowPlaying)

        #expect(info[MPMediaItemPropertyTitle] as? String == track.title)
        #expect(info[MPMediaItemPropertyArtist] as? String == track.artistName)
        #expect(info[MPMediaItemPropertyPlaybackDuration] as? Double == 200)
        #expect(info[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? Double == 10)
        #expect(info[MPNowPlayingInfoPropertyPlaybackRate] as? Double == 0)
    }

    @Test func detenerLimpiaTodo() async throws {
        let service = try await makePlayingService()

        service.stop()

        #expect(service.nowPlaying == nil)
        #expect(!engine.isPlaying)
        #expect(publisher.isCleared)
        #expect(!remoteCommands.isEnabled)
        #expect(session.deactivations == 1)
    }
}
