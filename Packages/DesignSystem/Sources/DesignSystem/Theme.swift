import SwiftUI

/// Colores y degradados del diseño Aeroglass.
public enum Theme {
    public static let ice = Color(hex: 0xEAF6FF)
    public static let frost = Color(hex: 0xBFE4FB)
    public static let sky = Color(hex: 0x5FB3EC)
    public static let azure = Color(hex: 0x1C7FC9)
    public static let rim = Color(hex: 0x0F6AA8)
    public static let navy = Color(hex: 0x06314F)
    public static let glow = Color(hex: 0x2E9AD8)
    public static let ocean = Color(hex: 0x0B3A63)
    public static let shadow = Color(hex: 0x041426)

    public static let error = Color(hex: 0xFFD7D7)
    public static let destructive = Color(hex: 0xFFB3B3)

    public static let secondaryText = Color.white.opacity(0.72)
    public static let tertiaryText = Color.white.opacity(0.58)

    static let backgroundStops = [
        Gradient.Stop(color: Color(hex: 0x0E4F82), location: 0),
        Gradient.Stop(color: Color(hex: 0x082E4F), location: 0.45),
        Gradient.Stop(color: Color(hex: 0x061D33), location: 1)
    ]

    /// Brillo clásico de Aero, con el corte duro a media altura.
    public static let gloss = LinearGradient(
        stops: [
            Gradient.Stop(color: ice, location: 0),
            Gradient.Stop(color: frost, location: 0.45),
            Gradient.Stop(color: sky, location: 0.46),
            Gradient.Stop(color: azure, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Relleno claro de los elementos seleccionados.
    public static let highlight = LinearGradient(colors: [ice, frost], startPoint: .top, endPoint: .bottom)

    public static let orb = LinearGradient(colors: [ice, azure], startPoint: .top, endPoint: .bottom)
}

extension Color {
    /// Color sRGB a partir de un valor `0xRRGGBB`.
    public init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    /// Color a partir de HSL, el modelo que usa el diseño (SwiftUI solo ofrece HSB).
    public init(hue: Int, saturationHSL: Double, lightness: Double) {
        let brightness = lightness + saturationHSL * min(lightness, 1 - lightness)
        let saturation = brightness == 0 ? 0 : 2 * (1 - lightness / brightness)
        self.init(hue: Double(hue) / 360, saturation: saturation, brightness: brightness)
    }

    /// Tinte de fondo asociado a una portada.
    public static func artworkTint(hue: Int) -> Color {
        Color(hue: hue, saturationHSL: 0.55, lightness: 0.52)
    }
}
