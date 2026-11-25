import SwiftUI

/// Botón principal con el brillo Aero.
public struct AeroPrimaryButtonStyle: ButtonStyle {
    private let isCapsule: Bool

    public init(isCapsule: Bool = false) {
        self.isCapsule = isCapsule
    }

    public func makeBody(configuration: Configuration) -> some View {
        let shape = isCapsule
            ? AnyShape(Capsule())
            : AnyShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        return configuration.label
            .font(.body.bold())
            .foregroundStyle(Theme.navy)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background {
                ZStack {
                    shape.fill(Theme.gloss)
                    // Destello diagonal.
                    GeometryReader { proxy in
                        Rectangle()
                            .fill(.white.opacity(0.4))
                            .frame(width: proxy.size.width * 0.35, height: proxy.size.height * 2.2)
                            .rotationEffect(.degrees(12))
                            .offset(x: -proxy.size.width * 0.12, y: -proxy.size.height * 0.5)
                            .blur(radius: 4)
                    }
                    .clipShape(shape)
                }
            }
            .glassEffect(.regular.interactive(), in: shape)
            .overlay { shape.stroke(Theme.rim, lineWidth: 1).allowsHitTesting(false) }
            .contentShape(shape)
            .shadow(color: Theme.ocean.opacity(0.5), radius: 8, y: 5)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

/// Botón secundario de cristal translúcido.
public struct AeroSecondaryButtonStyle: ButtonStyle {
    private let foreground: Color

    public init(foreground: Color = .white) {
        self.foreground = foreground
    }

    public func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

        return configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(foreground)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .contentShape(shape)
            .aeroGlass(.subtle, in: shape)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

/// Botón redondo de cristal con un símbolo del sistema.
public struct AeroCircleButton: View {
    private let systemImage: String
    private let accessibilityLabel: String
    private let action: () -> Void

    public init(systemImage: String, accessibilityLabel: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
                .aeroGlass(.subtle, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// Esfera azul brillante para reproducir o pausar.
public struct AeroOrbButton: View {
    private let systemImage: String
    private let size: CGFloat
    private let accessibilityLabel: String
    private let action: () -> Void

    public init(systemImage: String, size: CGFloat, accessibilityLabel: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(Theme.navy)
                .frame(width: size, height: size)
                .background(Theme.gloss, in: Circle())
                .glassEffect(.regular.interactive(), in: Circle())
                .overlay { Circle().stroke(Theme.rim, lineWidth: 1).allowsHitTesting(false) }
                .shadow(color: Theme.ocean.opacity(0.5), radius: 8, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// Etiqueta en forma de píldora clara.
public struct AeroBadge: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(Theme.navy)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.highlight, in: Capsule())
    }
}
