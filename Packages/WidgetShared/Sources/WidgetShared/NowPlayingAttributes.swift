import ActivityKit
import Foundation

/// Datos de la Live Activity "Reproduciendo ahora".
public struct NowPlayingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public let title: String
        public let artistName: String
        public let albumTitle: String
        public let artworkHue: Int
        /// Avance entre 0 y 1.
        public let progress: Double
        public let isPlaying: Bool

        public init(
            title: String,
            artistName: String,
            albumTitle: String,
            artworkHue: Int,
            progress: Double,
            isPlaying: Bool
        ) {
            self.title = title
            self.artistName = artistName
            self.albumTitle = albumTitle
            self.artworkHue = artworkHue
            self.progress = progress
            self.isPlaying = isPlaying
        }

        public var subtitle: String { "\(artistName) — \(albumTitle)" }
    }

    public init() {}
}

/// Contenido fijo del widget hasta que la app comparta datos reales mediante un App Group.
public enum NowPlayingSample {
    public static let trackID = "itit-2"

    public static let state = NowPlayingAttributes.ContentState(
        title: "Last Nite",
        artistName: "The Strokes",
        albumTitle: "Is This It",
        artworkHue: 205,
        progress: 0.34,
        isPlaying: true
    )
}

/// Enlace con el que el widget y la Live Activity abren el reproductor.
public enum VibraDeepLink {
    public static let scheme = "vibra"
    public static let playerHost = "player"
    public static let player = URL(string: "\(scheme)://\(playerHost)")
}
