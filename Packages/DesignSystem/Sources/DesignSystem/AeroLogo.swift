import SwiftUI

/// Logotipo de Vibra: barras de ecualizador dentro de un cristal con destello.
public struct AeroLogo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShining = false

    public init() {}

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: 30, style: .continuous)

        HStack(spacing: 7) {
            ForEach(Array([30, 54, 40, 62, 24].enumerated()), id: \.offset) { _, height in
                Capsule()
                    .fill(Theme.orb)
                    .frame(width: 9, height: CGFloat(height))
            }
        }
        .frame(width: 108, height: 108)
        .overlay {
            if !reduceMotion {
                Rectangle()
                    .fill(.white.opacity(0.4))
                    .frame(width: 44, height: 220)
                    .blur(radius: 6)
                    .rotationEffect(.degrees(8))
                    .offset(x: isShining ? 150 : -150)
                    .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: false), value: isShining)
                    .onAppear { isShining = true }
            }
        }
        .clipShape(shape)
        .aeroGlass(.prominent, in: shape)
        .accessibilityHidden(true)
    }
}

#Preview {
    AeroLogo()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AeroBackground() }
}
