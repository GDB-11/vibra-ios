import Domain
import Playback

/// Composición de dependencias de la app.
///
/// Para integrar el backend, sustituye aquí cada `Sample*` por su implementación de Networking.
/// Ninguna funcionalidad necesita cambiar.
struct AppEnvironment {
    let auth: any AuthRepository
    let catalog: any CatalogRepository
    let search: any SearchRepository
    let library: any LibraryRepository
    let streaming: any StreamingRepository
    let billing: any BillingRepository
    let playback: any PlaybackControlling

    static func sample() -> AppEnvironment {
        // TEMPORAL: ver PENDIENTE-fuente-de-audio.md.
        #if DEBUG
        let streaming = DebugStreamingRepository()
        #else
        let streaming = SampleStreamingRepository()
        #endif

        return AppEnvironment(
            auth: SampleAuthRepository(),
            catalog: SampleCatalogRepository(),
            search: SampleSearchRepository(),
            library: SampleLibraryRepository(),
            streaming: streaming,
            billing: SampleBillingRepository(),
            playback: PlaybackService(streaming: streaming)
        )
    }
}
