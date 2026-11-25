import DesignSystem
import Domain
import SwiftUI

/// Hoja para comprar un álbum completo para siempre o, como alternativa, suscribirse.
public struct AlbumPurchaseView: View {
    @State private var viewModel: AlbumPurchaseViewModel
    private let onSubscribe: () -> Void
    private let onClose: () -> Void

    public init(
        viewModel: AlbumPurchaseViewModel,
        onSubscribe: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSubscribe = onSubscribe
        self.onClose = onClose
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                header

                Button {
                    Task {
                        if await viewModel.buyAlbum() {
                            onClose()
                        }
                    }
                } label: {
                    Text(String(localized: "Comprar álbum — \(viewModel.album.price.formatted)"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AeroPrimaryButtonStyle())

                caption(String(localized: "Pago único. El álbum es tuyo para siempre, con o sin suscripción."))

                HStack(spacing: 10) {
                    divider
                    Text(String(localized: "o"))
                        .font(.footnote)
                        .foregroundStyle(Theme.tertiaryText)
                    divider
                }
                .padding(.vertical, 4)

                Button(action: onSubscribe) {
                    Text(String(localized: "Suscribirse"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AeroSecondaryButtonStyle())

                caption(String(localized: "Todo el catálogo mientras tu suscripción esté activa."))

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

    private var header: some View {
        VStack(spacing: 8) {
            CoverArtPlaceholder(hue: viewModel.album.artworkHue, cornerRadius: 16)
                .frame(width: 110, height: 110)
                .shadow(color: Theme.shadow.opacity(0.5), radius: 12, y: 8)
                .padding(.bottom, 4)
            Text(viewModel.album.title)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(verbatim: "\(viewModel.album.artistName) · \(String(localized: "\(viewModel.album.trackCount) canciones"))")
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.bottom, 12)
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.18))
            .frame(height: 1)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(Theme.secondaryText)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    VStack {
        if let album = SampleData.albums.last {
            AlbumPurchaseView(
                viewModel: AlbumPurchaseViewModel(album: album, billing: SampleBillingRepository()),
                onSubscribe: {},
                onClose: {}
            )
        }
    }
    .background { AeroBackground() }
    .preferredColorScheme(.dark)
}
