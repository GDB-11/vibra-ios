import DesignSystem
import Domain
import SwiftUI

public struct AuthView: View {
    @State private var viewModel: AuthViewModel
    private let onAuthenticated: () -> Void

    public init(viewModel: AuthViewModel, onAuthenticated: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(String(localized: "Vibra"))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                form
            }
            .padding(24)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical, alignment: .center)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .background { AeroBackground() }
    }

    private var form: some View {
        VStack(spacing: 14) {
            AeroSegmentedControl(
                segments: [
                    AeroSegment(AuthViewModel.Mode.login, title: String(localized: "Iniciar sesión")),
                    AeroSegment(AuthViewModel.Mode.register, title: String(localized: "Registrarse"))
                ],
                selection: $viewModel.mode
            )

            AeroTextField(String(localized: "Correo electrónico"), text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            AeroTextField(String(localized: "Contraseña"), text: $viewModel.password, isSecure: true)
                .textContentType(viewModel.mode == .login ? .password : .newPassword)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(Theme.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    if await viewModel.submit() {
                        onAuthenticated()
                    }
                }
            } label: {
                Text(viewModel.mode == .login ? String(localized: "Entrar") : String(localized: "Crear cuenta"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AeroPrimaryButtonStyle())
            .disabled(viewModel.isSubmitting)
        }
        .padding(22)
        .aeroCard(cornerRadius: 22)
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(repository: SampleAuthRepository()), onAuthenticated: {})
        .preferredColorScheme(.dark)
}
