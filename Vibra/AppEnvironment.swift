import Domain

/// Composición de dependencias de la app.
///
/// Para integrar el backend, sustituye aquí cada `Sample*` por su implementación de Networking
/// (y el reproductor por el de Playback). Ninguna funcionalidad necesita cambiar.
struct AppEnvironment {
    let auth: any AuthRepository
    let catalog: any CatalogRepository
    let search: any SearchRepository
    let library: any LibraryRepository
    let streaming: any StreamingRepository
    let billing: any BillingRepository
    let playback: any PlaybackControlling

    static func sample() -> AppEnvironment {
        AppEnvironment(
            auth: SampleAuthRepository(),
            catalog: SampleCatalogRepository(),
            search: SampleSearchRepository(),
            library: SampleLibraryRepository(),
            streaming: SampleStreamingRepository(),
            billing: SampleBillingRepository(),
            playback: SamplePlaybackController()
        )
    }
}
