import Domain
import MediaPlayer

/// Muestra la pista en la pantalla de bloqueo y en el Centro de control.
@MainActor
protocol NowPlayingPublishing: AnyObject {
    func publish(_ nowPlaying: NowPlaying)
    func clear()
}

@MainActor
final class SystemNowPlayingPublisher: NowPlayingPublishing {
    func publish(_ nowPlaying: NowPlaying) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = Self.info(for: nowPlaying)
    }

    func clear() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    /// El sistema calcula el avance a partir del tiempo transcurrido y la velocidad,
    /// así que no hace falta publicar cada segundo. La carátula llegará con las portadas reales.
    static func info(for nowPlaying: NowPlaying) -> [String: Any] {
        [
            MPMediaItemPropertyTitle: nowPlaying.track.title,
            MPMediaItemPropertyArtist: nowPlaying.track.artistName,
            MPMediaItemPropertyAlbumTitle: nowPlaying.track.albumTitle,
            MPMediaItemPropertyPlaybackDuration: Double(nowPlaying.durationSeconds),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: Double(nowPlaying.elapsedSeconds),
            MPNowPlayingInfoPropertyPlaybackRate: nowPlaying.isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
    }
}
