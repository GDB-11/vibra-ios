import DesignSystem
import Domain
import SwiftUI

public struct AccountView: View {
    @State private var viewModel: AccountViewModel
    private let onOpenSubscription: () -> Void
    private let onSignOut: () -> Void

    public init(
        viewModel: AccountViewModel,
        onOpenSubscription: @escaping () -> Void,
        onSignOut: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onOpenSubscription = onOpenSubscription
        self.onSignOut = onSignOut
    }

    public var body: some View {
        AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
            await viewModel.load()
        } content: { content in
            ScrollView {
                VStack(spacing: 16) {
                    profileCard(content.user)
                    settingsCard(content.entitlements)

                    Button {
                        Task {
                            await viewModel.signOut()
                            onSignOut()
                        }
                    } label: {
                        Text(String(localized: "Cerrar sesión"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(AeroSecondaryButtonStyle(foreground: Theme.destructive))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .background { AeroBackground() }
        .task { await viewModel.load() }
    }

    private func profileCard(_ user: UserProfile) -> some View {
        HStack(spacing: 14) {
            Text(user.initials)
                .font(.title3.bold())
                .foregroundStyle(Theme.navy)
                .frame(width: 52, height: 52)
                .background(Theme.orb, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(user.displayName)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
                Text(user.email)
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .aeroCard()
    }

    private func settingsCard(_ entitlements: Entitlements) -> some View {
        let planName = entitlements.hasActiveSubscription
            ? String(localized: "Premium")
            : String(localized: "Gratis")

        return VStack(spacing: 0) {
            Button(action: onOpenSubscription) {
                row(String(localized: "Suscripción"), detail: planName, showsChevron: true)
            }
            .buttonStyle(.plain)
            Divider().overlay(.white.opacity(0.14))
            row(String(localized: "Calidad de audio"), detail: String(localized: "FLAC sin pérdida"))
            Divider().overlay(.white.opacity(0.14))
            row(String(localized: "Idioma"), detail: String(localized: "Español"))
        }
        .aeroCard(.subtle, cornerRadius: 16)
    }

    private func row(_ title: String, detail: String, showsChevron: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)
            Spacer()
            Text(detail)
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Theme.tertiaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .contentShape(Rectangle())
    }
}

#Preview {
    AccountView(
        viewModel: AccountViewModel(auth: SampleAuthRepository(), billing: SampleBillingRepository()),
        onOpenSubscription: {},
        onSignOut: {}
    )
    .preferredColorScheme(.dark)
}
