import Domain
import Foundation
import Observation

@Observable
@MainActor
public final class AuthViewModel {
    public enum Mode: Hashable, Sendable {
        case login
        case register
    }

    public var mode: Mode = .login {
        didSet { errorMessage = nil }
    }
    public var email = ""
    public var password = ""
    public private(set) var errorMessage: String?
    public private(set) var isSubmitting = false

    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    /// Envía el formulario sin validarlo. Devuelve `true` si se puede entrar en la app.
    public func submit() async -> Bool {
        guard !isSubmitting else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        errorMessage = nil

        do {
            switch mode {
            case .login: try await repository.signIn(email: email, password: password)
            case .register: try await repository.register(email: email, password: password)
            }
            password = ""
            return true
        } catch {
            errorMessage = String(localized: "No se pudo continuar. Inténtalo de nuevo.")
            return false
        }
    }
}
