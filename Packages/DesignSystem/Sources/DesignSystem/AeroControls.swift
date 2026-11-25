import SwiftUI

/// Opción de un control segmentado.
public struct AeroSegment<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: String

    public var id: Value { value }

    public init(_ value: Value, title: String) {
        self.value = value
        self.title = title
    }
}

public struct AeroSegmentedControl<Value: Hashable>: View {
    private let segments: [AeroSegment<Value>]
    @Binding private var selection: Value

    public init(segments: [AeroSegment<Value>], selection: Binding<Value>) {
        self.segments = segments
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(segments) { segment in
                let isSelected = segment.value == selection
                Button {
                    selection = segment.value
                } label: {
                    Text(segment.title)
                        .font(.subheadline.weight(isSelected ? .bold : .semibold))
                        .foregroundStyle(isSelected ? Theme.navy : Theme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Theme.highlight)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Theme.shadow.opacity(0.3), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

/// Campo de texto claro sobre cristal.
public struct AeroTextField: View {
    private let placeholder: String
    private let isSecure: Bool
    private let isCapsule: Bool
    @Binding private var text: String

    public init(_ placeholder: String, text: Binding<String>, isSecure: Bool = false, isCapsule: Bool = false) {
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.isCapsule = isCapsule
        _text = text
    }

    public var body: some View {
        let shape = isCapsule
            ? AnyShape(Capsule())
            : AnyShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        let prompt: Text = Text(placeholder).foregroundStyle(Theme.navy.opacity(0.6))

        Group {
            if isSecure {
                SecureField(placeholder, text: $text, prompt: prompt)
            } else {
                TextField(placeholder, text: $text, prompt: prompt)
            }
        }
        .foregroundStyle(Theme.navy)
        .tint(Theme.rim)
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .aeroGlass(.light, in: shape)
    }
}

/// Barra de avance de solo lectura.
public struct ProgressTrack: View {
    private let progress: Double
    private let height: CGFloat

    public init(progress: Double, height: CGFloat = 6) {
        self.progress = progress
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.22))
                Capsule()
                    .fill(LinearGradient(colors: [Theme.ice, Theme.sky], startPoint: .leading, endPoint: .trailing))
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityLabel(String(localized: "Avance de la canción"))
        .accessibilityValue(progress.formatted(.percent.precision(.fractionLength(0))))
    }
}
