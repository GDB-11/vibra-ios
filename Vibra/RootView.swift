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
        .preferredColorScheme(.dark)
        // También se ejecuta al arrancar, así que cierra una Live Activity que hubiera quedado abierta.
        .task(id: environment.playback.nowPlaying) {
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

#Preview {
    RootView(environment: .sample())
}
