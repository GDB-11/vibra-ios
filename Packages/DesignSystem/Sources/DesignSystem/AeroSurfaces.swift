import SwiftUI

/// Fondo azul profundo con un resplandor superior.
public struct AeroBackground: View {
    private let tint: Color

    public init(tint: Color = Theme.glow) {
        self.tint = tint
    }

    public var body: some View {
        ZStack {
            LinearGradient(stops: Theme.backgroundStops, startPoint: .top, endPoint: .bottom)
            RadialGradient(
                colors: [tint, tint.opacity(0)],
                center: UnitPoint(x: 0.2, y: -0.05),
                startRadius: 0,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

/// Intensidad del velo blanco que se superpone al cristal.
public enum AeroGlassStyle: Sendable {
    /// Tarjetas destacadas y barras.
    case prominent
    /// Listas y filas agrupadas.
    case subtle
    /// Superficies claras que llevan texto azul oscuro.
    case light

    var opacities: (top: Double, bottom: Double) {
        switch self {
        case .prominent: (0.30, 0.07)
        case .subtle: (0.18, 0.04)
        case .light: (0.80, 0.55)
        }
    }
}

extension View {
    /// Cristal Aero: Liquid Glass nativo con el velo, el borde y el brillo del diseño.
    public func aeroGlass<S: Shape>(_ style: AeroGlassStyle = .prominent, in shape: S) -> some View {
        background {
            shape.fill(
                LinearGradient(
                    colors: [.white.opacity(style.opacities.top), .white.opacity(style.opacities.bottom)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .glassEffect(.regular, in: shape)
        .overlay {
            shape
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.75), .white.opacity(0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .allowsHitTesting(false)
        }
        .shadow(color: Theme.shadow.opacity(0.35), radius: 10, y: 6)
    }

    /// Cristal Aero con esquinas redondeadas.
    public func aeroCard(_ style: AeroGlassStyle = .prominent, cornerRadius: CGFloat = 18) -> some View {
        aeroGlass(style, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
