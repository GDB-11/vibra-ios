import AuthFeature
import Domain
import SwiftUI
import WidgetShared

/// Vista raíz: elige la fase de la app y atiende los enlaces del widget.
struct RootView: View {
    let environment: AppEnvironment
    @State private var router = AppRouter()

    var body: some View {
        Group {
            switch router.phase {
            case .splash:
                SplashView { router.phase = .auth }
            case .auth:
                AuthView(viewModel: AuthViewModel(repository: environment.auth)) {
                    router.enterApp()
                }
            case .main:
                MainShell(environment: environment, router: router)
            }
        }
        #if DEBUG
        // TEMPORAL: ver PENDIENTE-fuente-de-audio.md.
        .overlay(alignment: .top) {
            if router.phase == .main, let repository = environment.streaming as? DebugStreamingRepository {
                DebugStreamButton(repository: repository)
                    .padding(.top, 8)
            }
        }
        #endif
        .preferredColorScheme(.dark)
        // También se ejecuta al arrancar, así que cierra una Live Activity que hubiera quedado abierta.
        .task(id: LiveActivityRefreshKey(environment.playback.nowPlaying)) {
            await LiveActivityController.sync(with: environment.playback.nowPlaying)
        }
        .onOpenURL { handle($0) }
    }

    private func handle(_ url: URL) {
        // El widget nunca se salta el acceso: sin sesión, la app se queda donde está.
        guard url.scheme == VibraDeepLink.scheme,
              url.host() == VibraDeepLink.playerHost,
              router.phase == .main
        else { return }

        // El widget muestra una canción de ejemplo aunque todavía no se haya abierto ninguna.
        if environment.playback.nowPlaying == nil {
            guard let track = SampleData.tracks.first(where: { $0.id == NowPlayingSample.trackID }) else { return }
            environment.playback.play(track, isPreview: false)
        }
        router.present(.player)
    }
}

/// Cambia solo cuando merece la pena actualizar la Live Activity: el avance se agrupa
/// en tramos de 10 segundos para no actualizarla cada segundo.
private nonisolated struct LiveActivityRefreshKey: Equatable {
    let trackID: String?
    let isPlaying: Bool?
    let durationSeconds: Int?
    let progressStep: Int?

    init(_ nowPlaying: NowPlaying?) {
        trackID = nowPlaying?.track.id
        isPlaying = nowPlaying?.isPlaying
        durationSeconds = nowPlaying?.durationSeconds
        progressStep = nowPlaying.map { $0.elapsedSeconds / 10 }
    }
}

#Preview {
    RootView(environment: .sample())
}
