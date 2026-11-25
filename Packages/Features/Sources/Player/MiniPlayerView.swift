import DesignSystem
import Domain
import SwiftUI

/// Reproductor compacto que la app coloca sobre la barra de pestañas.
public struct MiniPlayerView: View {
    private let nowPlaying: NowPlaying
    private let onOpen: () -> Void
    private let onTogglePlayPause: () -> Void

    public init(nowPlaying: NowPlaying, onOpen: @escaping () -> Void, onTogglePlayPause: @escaping () -> Void) {
        self.nowPlaying = nowPlaying
        self.onOpen = onOpen
        self.onTogglePlayPause = onTogglePlayPause
    }

    public var body: some View {
        HStack(spacing: 10) {
            Button(action: onOpen) {
                HStack(spacing: 10) {
                    CoverArtPlaceholder(hue: nowPlaying.track.artworkHue, cornerRadius: 9)
                        .frame(width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(nowPlaying.track.title)
                            .font(.footnote.bold())
                            .foregroundStyle(Theme.navy)
                        Text(nowPlaying.track.albumTitle)
                            .font(.caption2)
                            .foregroundStyle(Theme.navy.opacity(0.75))
                    }
                    .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint(String(localized: "Abre el reproductor"))

            AeroOrbButton(
                systemImage: nowPlaying.isPlaying ? "pause.fill" : "play.fill",
                size: 34,
                accessibilityLabel: nowPlaying.isPlaying
                    ? String(localized: "Pausar")
                    : String(localized: "Reproducir"),
                action: onTogglePlayPause
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .aeroCard(.light, cornerRadius: 16)
    }
}

#Preview {
    VStack {
        if let track = SampleData.tracks.first {
            MiniPlayerView(
                nowPlaying: SamplePlaybackController.sample(track),
                onOpen: {},
                onTogglePlayPause: {}
            )
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background { AeroBackground() }
    .preferredColorScheme(.dark)
}
