import SwiftUI

/// Punto de entrada de la app. El objetivo se mantiene delgado:
/// composición, inyección de dependencias y navegación.
@main
struct VibraApp: App {
    private let environment = AppEnvironment.sample()

    var body: some Scene {
        WindowGroup {
            RootView(environment: environment)
        }
    }
}
