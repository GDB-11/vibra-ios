import Foundation

/// Resultado de `GET /v1/tracks/{id}/stream`.
public enum StreamAccess: Hashable, Sendable {
    /// `200`: URL firmada de la pista completa.
    case granted(url: URL)
    /// `403`: sin derechos; solo se ofrece la vista previa de 30 s.
    case locked(previewURL: URL)
}

public struct NowPlaying: Hashable, Sendable {
    public let track: Track
    public let elapsedSeconds: Int
    public let durationSeconds: Int
    public let isPlaying: Bool
    public let isPreview: Bool

    public init(track: Track, elapsedSeconds: Int, durationSeconds: Int, isPlaying: Bool, isPreview: Bool) {
        self.track = track
        self.elapsedSeconds = elapsedSeconds
        self.durationSeconds = durationSeconds
        self.isPlaying = isPlaying
        self.isPreview = isPreview
    }

    /// Avance entre 0 y 1.
    public var progress: Double {
        guard durationSeconds > 0 else { return 0 }
        return min(max(Double(elapsedSeconds) / Double(durationSeconds), 0), 1)
    }

    public var remainingSeconds: Int {
        max(durationSeconds - elapsedSeconds, 0)
    }
}
