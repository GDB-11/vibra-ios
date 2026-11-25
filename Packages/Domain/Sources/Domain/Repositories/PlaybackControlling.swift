/// Intenciones de reproducción. La implementación real la dará el paquete Playback.
///
/// La implementación debe ser `@Observable` para que las vistas reaccionen a `nowPlaying`.
@MainActor
public protocol PlaybackControlling: AnyObject {
    var nowPlaying: NowPlaying? { get }

    func play(_ track: Track, isPreview: Bool)
    func togglePlayPause()
    func skipToNext()
    func skipToPrevious()
    func stop()
}
