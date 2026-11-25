import SwiftUI

/// Punto de entrada de la app. El objetivo se mantiene delgado:
/// composición, inyección de dependencias y navegación.
@main
struct VibraApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
