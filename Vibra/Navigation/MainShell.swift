import DesignSystem
import Domain
import HomeFeature
import LibraryFeature
import PlayerFeature
import SearchFeature
import SettingsFeature
import SubscriptionFeature
import SwiftUI

/// Pestañas, barra inferior y presentaciones de la parte autenticada.
struct MainShell: View {
    let environment: AppEnvironment
    @Bindable var router: AppRouter

    @State private var hasActiveSubscription = false

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Tab(tab.title, systemImage: tab.systemImage, value: tab) {
                        stack(for: tab)
                    }
                }
            }
            .tabViewStyle(.tabBarOnly)

            bottomBar
        }
        .background { AeroBackground() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(item: $router.lockedTrack, onDismiss: { router.lockedSheetDidDismiss() }) { track in
            lockedSheet(for: track)
        }
        .fullScreenCover(item: $router.cover) { cover in
            coverContent(cover)
        }
        .task {
            // Si falla, la insignia se queda en "Gratis".
            let entitlements = try? await environment.billing.entitlements()
            hasActiveSubscription = entitlements?.hasActiveSubscription ?? false
        }
    }

    // MARK: - Pestañas

    private func stack(for tab: AppTab) -> some View {
        let path = Binding(
            get: { router.paths[tab] ?? [] },
            set: { router.paths[tab] = $0 }
        )

        return NavigationStack(path: path) {
            VStack(spacing: 0) {
                header
                root(for: tab)
            }
            .background { AeroBackground() }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .toolbarVisibility(.hidden, for: .tabBar)
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(String(localized: "Vibra"))
                .font(.title2.bold())
                .foregroundStyle(.white)
            Spacer()
            Button {
                router.present(.paywall)
            } label: {
                AeroBadge(hasActiveSubscription ? String(localized: "Premium") : String(localized: "Gratis"))
            }
            .buttonStyle(.plain)
            .accessibilityHint(String(localized: "Muestra los planes"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func root(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView(
                viewModel: HomeViewModel(catalog: environment.catalog, library: environment.library),
                onSelectArtist: { router.push(.artist(id: $0.id)) },
                onSelectAlbum: { router.push(.album(id: $0.id)) },
                onSelectTrack: { open($0) }
            )
        case .search:
            SearchView(
                viewModel: SearchViewModel(repository: environment.search),
                onSelectTrack: { open($0) }
            )
        case .library:
            LibraryView(
                viewModel: LibraryViewModel(repository: environment.library),
                onSelectPlaylist: { router.push(.playlist(id: $0.id)) },
                onSelectTrack: { open($0) }
            )
        case .account:
            AccountView(
                viewModel: AccountViewModel(auth: environment.auth, billing: environment.billing),
                onOpenSubscription: { router.present(.paywall) },
                onSignOut: {
                    environment.playback.stop()
                    router.signOut()
                }
            )
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .album(let id):
            AlbumDetailView(
                viewModel: AlbumDetailViewModel(
                    albumID: id,
                    catalog: environment.catalog,
                    library: environment.library
                ),
                onSelectTrack: { open($0) },
                onBuyAlbum: { router.present(.paywall) }
            )
        case .artist(let id):
            ArtistView(
                viewModel: ArtistViewModel(artistID: id, catalog: environment.catalog),
                onSelectAlbum: { router.push(.album(id: $0.id)) }
            )
        case .playlist(let id):
            PlaylistDetailView(
                viewModel: PlaylistDetailViewModel(playlistID: id, repository: environment.library),
                onSelectTrack: { open($0) }
            )
        }
    }

    // MARK: - Barra inferior

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if let nowPlaying = environment.playback.nowPlaying {
                MiniPlayerView(
                    nowPlaying: nowPlaying,
                    onOpen: { router.present(.player) },
                    onTogglePlayPause: { environment.playback.togglePlayPause() }
                )
                .padding(.horizontal, 12)
            }
            AeroTabBar(selection: $router.selectedTab) { tab in
                // Tocar la pestaña activa vuelve a su pantalla inicial.
                router.paths[tab] = []
            }
        }
        .padding(.top, 6)
    }

    // MARK: - Presentaciones

    /// En la integración real, un `403` de `streaming.streamAccess` abrirá la hoja de bloqueo.
    private func open(_ track: Track) {
        if track.isLocked {
            router.lockedTrack = track
        } else {
            environment.playback.play(track, isPreview: false)
            router.present(.player)
        }
    }

    private func lockedSheet(for track: Track) -> some View {
        LockedContentView(
            viewModel: LockedContentViewModel(track: track, billing: environment.billing),
            onPlayPreview: {
                environment.playback.play(track, isPreview: true)
                router.present(.player)
            },
            onSubscribe: { router.present(.paywall) },
            onClose: { router.lockedTrack = nil }
        )
        .presentationDetents([.height(520), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground {
            LinearGradient(
                colors: [Theme.ocean.opacity(0.92), Theme.shadow.opacity(0.96)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    @ViewBuilder
    private func coverContent(_ cover: Cover) -> some View {
        switch cover {
        case .player:
            PlayerView(
                viewModel: PlayerViewModel(playback: environment.playback, library: environment.library),
                onMinimize: { router.cover = nil }
            )
        case .paywall:
            PaywallView(
                viewModel: PaywallViewModel(billing: environment.billing),
                onClose: { router.cover = nil }
            )
        }
    }
}
