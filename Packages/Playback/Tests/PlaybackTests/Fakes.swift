import Domain
import Foundation

@testable import Playback

@MainActor
final class FakeAudioEngine: AudioEngine {
    var onEvent: (@MainActor (AudioEngineEvent) -> Void)?
    private(set) var loadedURLs: [URL] = []
    private(set) var seeks: [Double] = []
    private(set) var isPlaying = false

    func load(_ url: URL) { loadedURLs.append(url) }
    func play() { isPlaying = true }
    func pause() { isPlaying = false }
    func seek(to seconds: Double) { seeks.append(seconds) }
    func reset() { isPlaying = false }
}

@MainActor
final class FakeAudioSession: AudioSessionControlling {
    var onEvent: (@MainActor (AudioSessionEvent) -> Void)?
    private(set) var activations = 0
    private(set) var deactivations = 0

    func activate() throws { activations += 1 }
    func deactivate() { deactivations += 1 }
}

@MainActor
final class FakeNowPlayingPublisher: NowPlayingPublishing {
    private(set) var published: [NowPlaying] = []
    private(set) var isCleared = false

    func publish(_ nowPlaying: NowPlaying) {
        published.append(nowPlaying)
        isCleared = false
    }

    func clear() { isCleared = true }
}

@MainActor
final class FakeRemoteCommands: RemoteCommandHandling {
    var onCommand: (@MainActor (RemoteCommand) -> Void)?
    private(set) var isEnabled = false

    func enable() { isEnabled = true }
    func disable() { isEnabled = false }
}

struct FakeStreamingError: Error {}

/// Responde al instante con el acceso configurado, o falla si no hay ninguno.
struct FakeStreaming: StreamingRepository {
    let access: StreamAccess?

    func streamAccess(trackID: String) async throws -> StreamAccess {
        guard let access else { throw FakeStreamingError() }
        return access
    }
}

/// Retiene cada petición hasta que la prueba la resuelve, para controlar el orden de llegada.
actor GatedStreaming: StreamingRepository {
    private var pending: [String: CheckedContinuation<StreamAccess, Never>] = [:]

    func streamAccess(trackID: String) async throws -> StreamAccess {
        await withCheckedContinuation { pending[trackID] = $0 }
    }

    func waitForRequest(trackID: String) async {
        while pending[trackID] == nil {
            await Task.yield()
        }
    }

    func resolve(trackID: String, with access: StreamAccess) {
        pending.removeValue(forKey: trackID)?.resume(returning: access)
    }
}
