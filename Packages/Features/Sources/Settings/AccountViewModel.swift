import Domain
import Observation

public struct AccountContent: Sendable {
    public let user: UserProfile
    public let entitlements: Entitlements
}

@Observable
@MainActor
public final class AccountViewModel {
    public private(set) var state: LoadState<AccountContent> = .idle

    private let auth: any AuthRepository
    private let billing: any BillingRepository

    public init(auth: any AuthRepository, billing: any BillingRepository) {
        self.auth = auth
        self.billing = billing
    }

    public func load() async {
        state = state.reloading
        do {
            let user = try await auth.currentUser()
            let entitlements = try await billing.entitlements()
            state = .loaded(AccountContent(user: user, entitlements: entitlements))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }

    /// Cierra la sesión local aunque falle la llamada remota.
    public func signOut() async {
        try? await auth.signOut()
    }
}
