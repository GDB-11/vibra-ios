import DesignSystem
import SwiftUI
import WidgetShared

// Los widgets no pueden desenfocar en vivo de forma fiable, así que el cristal se simula con degradados.
// Los controles son solo visuales: para que respondan hará falta App Intents.

/// Portada, título y artista.
struct NowPlayingHeader: View {
    let state: NowPlayingAttributes.ContentState
    let artworkSize: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            CoverArtPlaceholder(hue: state.artworkHue, cornerRadius: artworkSize * 0.2)
                .frame(width: artworkSize, height: artworkSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(state.title)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
                Text(state.subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Esfera con el estado de reproducción.
struct PlayStateOrb: View {
    let isPlaying: Bool
    let size: CGFloat

    var body: some View {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: size * 0.4, weight: .bold))
            .foregroundStyle(Theme.navy)
            .frame(width: size, height: size)
            .background(Theme.gloss, in: Circle())
            .overlay { Circle().stroke(Theme.rim, lineWidth: 1) }
            .accessibilityHidden(true)
    }
}

/// Velo claro con borde que imita el cristal Aero.
struct GlassSheen: View {
    var body: some View {
        LinearGradient(
            colors: [.white.opacity(0.26), .white.opacity(0.04)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
