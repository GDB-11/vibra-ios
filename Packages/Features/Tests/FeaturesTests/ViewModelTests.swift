import Domain
import Testing

import AuthFeature
import HomeFeature
import LibraryFeature
import PlayerFeature
import SearchFeature
import SettingsFeature
import SubscriptionFeature

@MainActor
struct ViewModelTests {
    @Test func accesoEntraSinValidarLosCampos() async {
        let viewModel = AuthViewModel(repository: SampleAuthRepository())

        let didEnter = await viewModel.submit()

        #expect(didEnter)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func inicioCargaElCatalogoDeEjemplo() async {
        let viewModel = HomeViewModel(catalog: SampleCatalogRepository(), library: SampleLibraryRepository())

        await viewModel.load()

        #expect(viewModel.state.value?.albums.count == 6)
        #expect(viewModel.state.value?.recentlyPlayed.isEmpty == false)
    }

    @Test func albumInexistenteTerminaEnError() async {
        let viewModel = AlbumDetailViewModel(
            albumID: "no-existe",
            catalog: SampleCatalogRepository(),
            library: SampleLibraryRepository()
        )

        await viewModel.load()

        #expect(viewModel.state.hasFailed)
    }

    @Test func artistaCargaSusAlbumes() async {
        let viewModel = ArtistViewModel(artistID: SampleData.artist.id, catalog: SampleCatalogRepository())

        await viewModel.load()

        #expect(viewModel.state.value?.albums.count == SampleData.artist.albumCount)
    }

    @Test func busquedaSinResultadosQuedaVacia() async {
        let viewModel = SearchViewModel(repository: SampleSearchRepository(isEmpty: true))
        viewModel.query = "nada"

        await viewModel.search()

        #expect(viewModel.state.value?.isEmpty == true)
        #expect(viewModel.searchedQuery == "nada")
    }

    @Test(arguments: SampleData.playlists)
    func cadaListaTieneLasCancionesQueAnuncia(playlist: Playlist) async {
        let viewModel = PlaylistDetailViewModel(playlistID: playlist.id, repository: SampleLibraryRepository())

        await viewModel.load()

        #expect(viewModel.state.value?.tracks.count == playlist.trackCount)
    }

    @Test func bibliotecaCargaSusTresSecciones() async {
        let viewModel = LibraryViewModel(repository: SampleLibraryRepository())

        await viewModel.load()

        #expect(viewModel.state.value?.playlists.count == 3)
        #expect(viewModel.state.value?.likedTracks.isEmpty == false)
        #expect(viewModel.state.value?.history.isEmpty == false)
    }

    @Test func reproductorReflejaLaPistaAbierta() throws {
        let playback = SamplePlaybackController()
        let viewModel = PlayerViewModel(playback: playback, library: SampleLibraryRepository())
        let track = try #require(SampleData.tracks.first)

        playback.play(track, isPreview: true)

        #expect(viewModel.nowPlaying?.track == track)
        #expect(viewModel.nowPlaying?.durationSeconds == 30)
    }

    @Test func muroDePagoCalculaElAhorroAnual() async {
        let viewModel = PaywallViewModel(billing: SampleBillingRepository())

        await viewModel.load()

        #expect(viewModel.annualSavingsPercent == 25)
    }

    @Test func cuentaCargaElPerfil() async {
        let viewModel = AccountViewModel(auth: SampleAuthRepository(), billing: SampleBillingRepository())

        await viewModel.load()

        #expect(viewModel.state.value?.user.initials == "JS")
    }
}
