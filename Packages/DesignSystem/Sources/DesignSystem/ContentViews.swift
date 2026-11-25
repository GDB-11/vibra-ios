import SwiftUI

/// Portada provisional a rayas mientras no haya imágenes reales.
public struct CoverArtPlaceholder: View {
    private let hue: Int
    private let cornerRadius: CGFloat
    private let caption: String?

    public init(hue: Int, cornerRadius: CGFloat = 14, caption: String? = nil) {
        self.hue = hue
        self.cornerRadius = cornerRadius
        self.caption = caption
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        shape
            .fill(LinearGradient(stops: stripes, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                if let caption {
                    ZStack {
                        Theme.shadow.opacity(0.4)
                        Text(caption)
                            .font(.caption2.monospaced())
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.92))
                            .padding(8)
                    }
                    .clipShape(shape)
                }
            }
            .overlay { shape.stroke(.white.opacity(0.32), lineWidth: 1) }
            .accessibilityHidden(true)
    }

    private var stripes: [Gradient.Stop] {
        let light = Color(hue: hue, saturationHSL: 0.55, lightness: 0.6)
        let dark = Color(hue: hue, saturationHSL: 0.45, lightness: 0.39)
        let count = 10
        return (0..<count).flatMap { index in
            let color = index.isMultiple(of: 2) ? light : dark
            return [
                Gradient.Stop(color: color, location: Double(index) / Double(count)),
                Gradient.Stop(color: color, location: Double(index + 1) / Double(count))
            ]
        }
    }
}

/// Fila de una canción: portada o número, textos, candado y duración.
public struct TrackRow: View {
    public enum Leading {
        case artwork(hue: Int)
        case number(Int)
    }

    private let leading: Leading
    private let title: String
    private let subtitle: String?
    private let duration: String?
    private let isLocked: Bool
    private let action: () -> Void

    public init(
        leading: Leading,
        title: String,
        subtitle: String? = nil,
        duration: String? = nil,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) {
        self.leading = leading
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.isLocked = isLocked
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                switch leading {
                case .artwork(let hue):
                    CoverArtPlaceholder(hue: hue, cornerRadius: 9)
                        .frame(width: 44, height: 44)
                case .number(let number):
                    Text(number.formatted())
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(Theme.tertiaryText)
                        .frame(width: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Theme.tertiaryText)
                    }
                }
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                        .accessibilityLabel(String(localized: "Bloqueada"))
                }
                if let duration {
                    Text(duration)
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(Theme.tertiaryText)
                }
            }
            .padding(.vertical, 9)
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Título de sección.
public struct SectionTitle: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.callout.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Mensaje centrado para listas vacías.
public struct EmptyStateView: View {
    private let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .font(.footnote)
            .foregroundStyle(Theme.tertiaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .padding(.horizontal, 10)
    }
}

/// Muestra la carga, el error o el contenido de una pantalla.
public struct AsyncContentView<Value, Content: View>: View {
    private let value: Value?
    private let hasFailed: Bool
    private let retry: @MainActor () async -> Void
    private let content: (Value) -> Content

    public init(
        value: Value?,
        hasFailed: Bool,
        retry: @escaping @MainActor () async -> Void,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.value = value
        self.hasFailed = hasFailed
        self.retry = retry
        self.content = content
    }

    public var body: some View {
        if let value {
            content(value)
        } else if hasFailed {
            VStack(spacing: 14) {
                Text(String(localized: "No se pudo cargar el contenido."))
                    .font(.subheadline)
                    .foregroundStyle(Theme.error)
                    .multilineTextAlignment(.center)
                Button(String(localized: "Reintentar")) {
                    Task { await retry() }
                }
                .buttonStyle(AeroSecondaryButtonStyle())
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview("Error") {
    AsyncContentView(value: String?.none, hasFailed: true, retry: {}) { Text($0) }
        .background { AeroBackground() }
}
