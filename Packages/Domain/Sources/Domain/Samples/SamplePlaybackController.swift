import Observation

/// Reproductor simulado: recuerda qué pista se abrió, sin audio y con un avance fijo.
@Observable
@MainActor
public final class SamplePlaybackController: PlaybackControlling {
    public private(set) var nowPlaying: NowPlaying?

    public init(nowPlaying: NowPlaying? = nil) {
        self.nowPlaying = nowPlaying
    }

    public func play(_ track: Track, isPreview: Bool) {
        nowPlaying = Self.sample(track, isPreview: isPreview)
    }

    public func togglePlayPause() {}
    public func skipToNext() {}
    public func skipToPrevious() {}

    public func stop() {
        nowPlaying = nil
    }

    public static func sample(_ track: Track, isPreview: Bool = false) -> NowPlaying {
        NowPlaying(
            track: track,
            elapsedSeconds: isPreview ? 8 : 61,
            durationSeconds: isPreview ? 30 : track.durationSeconds,
            isPlaying: true,
            isPreview: isPreview
        )
    }
}
