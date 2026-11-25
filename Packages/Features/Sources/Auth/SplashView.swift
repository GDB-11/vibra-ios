import DesignSystem
import SwiftUI

public struct SplashView: View {
    private let onBegin: () -> Void

    public init(onBegin: @escaping () -> Void) {
        self.onBegin = onBegin
    }

    public var body: some View {
        VStack(spacing: 28) {
            AeroLogo()
            VStack(spacing: 10) {
                Text(String(localized: "Vibra"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text(String(localized: "Todo el catálogo, o solo lo que amas."))
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            Button(String(localized: "Comenzar"), action: onBegin)
                .buttonStyle(AeroPrimaryButtonStyle(isCapsule: true))
                .padding(.top, 14)
        }
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AeroBackground() }
    }
}

#Preview {
    SplashView(onBegin: {})
        .preferredColorScheme(.dark)
}
