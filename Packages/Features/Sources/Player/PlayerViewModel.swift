import Domain
import Observation

@Observable
@MainActor
public final class PlayerViewModel {
    private let playback: any PlaybackControlling
    private let library: any LibraryRepository

    public init(playback: any PlaybackControlling, library: any LibraryRepository) {
        self.playback = playback
        self.library = library
    }

    public var nowPlaying: NowPlaying? { playback.nowPlaying }

    public func togglePlayPause() { playback.togglePlayPause() }
    public func skipToNext() { playback.skipToNext() }
    public func skipToPrevious() { playback.skipToPrevious() }

    /// El estado del corazón llegará del backend; por ahora solo se envía la intención.
    public func likeCurrentTrack() async {
        guard let track = nowPlaying?.track else { return }
        // Con datos de ejemplo no cambia nada. Falta mostrar el error cuando exista el backend.
        try? await library.setTrackLiked(true, trackID: track.id)
    }
}
