import Domain
import Foundation
import Observation

nonisolated enum AppPhase {
    case splash
    case auth
    case main
}

nonisolated enum AppTab: CaseIterable, Hashable {
    case home
    case search
    case library
    case account

    var title: String {
        switch self {
        case .home: String(localized: "Inicio")
        case .search: String(localized: "Buscar")
        case .library: String(localized: "Biblioteca")
        case .account: String(localized: "Cuenta")
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .search: "magnifyingglass"
        case .library: "books.vertical.fill"
        case .account: "person.crop.circle.fill"
        }
    }
}

/// Páginas que se apilan dentro de una pestaña.
nonisolated enum Route: Hashable {
    case album(id: String)
    case artist(id: String)
    case playlist(id: String)
}

/// Presentaciones a pantalla completa.
nonisolated enum Cover: String, Identifiable {
    case player
    case paywall

    var id: String { rawValue }
}

/// Única fuente de verdad de la navegación entre funcionalidades.
@Observable
final class AppRouter {
    var phase: AppPhase = .splash
    var selectedTab: AppTab = .home
    var paths: [AppTab: [Route]] = [:]
    var lockedTrack: Track?
    var cover: Cover?

    /// Cobertura que se presentará cuando termine de cerrarse la hoja.
    private var pendingCover: Cover?

    func push(_ route: Route) {
        paths[selectedTab, default: []].append(route)
    }

    /// SwiftUI no puede presentar sobre una hoja que se está cerrando, así que espera a `onDismiss`.
    func present(_ newCover: Cover) {
        if lockedTrack == nil {
            cover = newCover
        } else {
            pendingCover = newCover
            lockedTrack = nil
        }
    }

    func lockedSheetDidDismiss() {
        guard let pendingCover else { return }
        self.pendingCover = nil
        cover = pendingCover
    }

    func enterApp() {
        phase = .main
    }

    func signOut() {
        phase = .auth
        selectedTab = .home
        paths = [:]
        lockedTrack = nil
        pendingCover = nil
        cover = nil
    }
}
