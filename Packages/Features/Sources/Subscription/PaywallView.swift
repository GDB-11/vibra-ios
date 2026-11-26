import DesignSystem
import Domain
import SwiftUI

public struct PaywallView: View {
    @State private var viewModel: PaywallViewModel
    private let onClose: () -> Void

    public init(viewModel: PaywallViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                AeroCircleButton(
                    systemImage: "xmark",
                    accessibilityLabel: String(localized: "Cerrar"),
                    action: onClose
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
                await viewModel.load()
            } content: { plans in
                ScrollView {
                    content(plans)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 10)
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .background { AeroBackground() }
        .task { await viewModel.load() }
    }

    private func content(_ plans: [Plan]) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(String(localized: "Elige tu plan"))
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .accessibilityAddTraits(.isHeader)
                Text(String(localized: "Acceso ilimitado a todo el catálogo de Vibra en calidad FLAC sin pérdida."))
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                ForEach(plans) { plan in
                    planCard(plan)
                }
            }

            Button {
                Task {
                    if await viewModel.subscribe() {
                        onClose()
                    }
                }
            } label: {
                Text(String(localized: "Comenzar suscripción"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AeroPrimaryButtonStyle())

            Text(String(localized: "Pago simulado para fines educativos. Se renueva automáticamente; cancela cuando quieras."))
                .font(.caption)
                .foregroundStyle(Theme.tertiaryText)
                .multilineTextAlignment(.center)

            Divider().overlay(.white.opacity(0.15))

            Text(String(localized: "O compra álbumes y pistas por separado desde su página."))
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.restorePurchases() }
            } label: {
                Text(String(localized: "Restaurar compras"))
                    .font(.footnote)
                    .underline()
                    .foregroundStyle(Theme.secondaryText)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
    }

    private func planCard(_ plan: Plan) -> some View {
        let isSelected = viewModel.selectedPlan == plan.interval
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)

        return Button {
            viewModel.selectedPlan = plan.interval
        } label: {
            HStack {
                Text(name(of: plan.interval))
                Spacer()
                Text(priceLabel(of: plan))
            }
            .font(.callout.bold())
            .foregroundStyle(.white)
            .padding(18)
            .contentShape(shape)
            .aeroGlass(isSelected ? .prominent : .subtle, in: shape)
            .overlay {
                if isSelected {
                    shape.stroke(Theme.ice, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if plan.interval == .annual,let savings = viewModel.annualSavingsPercent {
                AeroBadge(String(localized: "AHORRA \((Double(savings) / 100).formatted(.percent))"))
                    .offset(x: -14, y: -12)
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func name(of interval: Plan.Interval) -> String {
        switch interval {
        case .monthly: String(localized: "Mensual")
        case .annual: String(localized: "Anual")
        }
    }

    private func priceLabel(of plan: Plan) -> String {
        switch plan.interval {
        case .monthly: String(localized: "\(plan.price.formatted)/mes")
        case .annual: String(localized: "\(plan.price.formatted)/año")
        }
    }
}

#Preview {
    PaywallView(viewModel: PaywallViewModel(billing: SampleBillingRepository()), onClose: {})
        .preferredColorScheme(.dark)
}
