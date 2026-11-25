import DesignSystem
import Domain
import SwiftUI

/// Hoja de contenido bloqueado: la respuesta `403` con vista previa.
public struct LockedContentView: View {
    @State private var viewModel: LockedContentViewModel
    private let onPlayPreview: () -> Void
    private let onSubscribe: () -> Void
    private let onClose: () -> Void

    public init(
        viewModel: LockedContentViewModel,
        onPlayPreview: @escaping () -> Void,
        onSubscribe: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onPlayPreview = onPlayPreview
        self.onSubscribe = onSubscribe
        self.onClose = onClose
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(Theme.orb)
                    .padding(.bottom, 8)
                    .accessibilityHidden(true)

                Text(String(localized: "Contenido bloqueado"))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "\"\(viewModel.track.title)\" requiere una suscripción o la compra de la pista. Puedes escuchar una vista previa de 30 segundos."))
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                Button(action: onPlayPreview) {
                    Label(String(localized: "Vista previa de 30 s"), systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AeroSecondaryButtonStyle())

                Button(action: onSubscribe) {
                    Text(String(localized: "Suscribirse"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AeroPrimaryButtonStyle())

                Button {
                    Task {
                        if await viewModel.buyTrack() {
                            onClose()
                        }
                    }
                } label: {
                    Text(String(localized: "Comprar esta pista — \(viewModel.track.price.formatted)"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AeroSecondaryButtonStyle())

                Button(String(localized: "Cancelar"), action: onClose)
                    .font(.footnote)
                    .foregroundStyle(Theme.tertiaryText)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal, 22)
            .padding(.top, 30)
            .padding(.bottom, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    VStack {
        if let track = SampleData.tracks.last {
            LockedContentView(
                viewModel: LockedContentViewModel(track: track, billing: SampleBillingRepository()),
                onPlayPreview: {},
                onSubscribe: {},
                onClose: {}
            )
        }
    }
    .background { AeroBackground() }
    .preferredColorScheme(.dark)
}
