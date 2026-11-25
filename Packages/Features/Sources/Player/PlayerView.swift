import DesignSystem
import Domain
import SwiftUI

public struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    private let onMinimize: () -> Void

    public init(viewModel: PlayerViewModel, onMinimize: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onMinimize = onMinimize
    }

    public var body: some View {
        VStack(spacing: 0) {
            topBar
            if let nowPlaying = viewModel.nowPlaying {
                ScrollView {
                    content(nowPlaying)
                        .padding(.horizontal, 30)
                        .containerRelativeFrame(.vertical, alignment: .center)
                }
                .scrollBounceBehavior(.basedOnSize)
            } else {
                EmptyStateView(String(localized: "No hay nada en reproducción."))
                    .frame(maxHeight: .infinity)
            }
        }
        .background {
            AeroBackground(
                tint: viewModel.nowPlaying.map { Color.artworkTint(hue: $0.track.artworkHue) } ?? Theme.glow
            )
        }
    }

    private var topBar: some View {
        HStack {
            AeroCircleButton(
                systemImage: "chevron.down",
                accessibilityLabel: String(localized: "Minimizar reproductor"),
                action: onMinimize
            )
            Spacer()
            Text(String(localized: "Reproduciendo"))
                .font(.caption.bold())
                .textCase(.uppercase)
                .kerning(1)
                .foregroundStyle(Theme.secondaryText)
            Spacer()
            AeroCircleButton(systemImage: "heart", accessibilityLabel: String(localized: "Me gusta")) {
                Task { await viewModel.likeCurrentTrack() }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func content(_ nowPlaying: NowPlaying) -> some View {
        VStack(spacing: 26) {
            CoverArtPlaceholder(
                hue: nowPlaying.track.artworkHue,
                cornerRadius: 22,
                caption: String(localized: "PORTADA DEL ÁLBUM\n\(nowPlaying.track.albumTitle)")
            )
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 270)
            .shadow(color: Theme.shadow.opacity(0.6), radius: 24, y: 18)

            VStack(spacing: 5) {
                if nowPlaying.isPreview {
                    AeroBadge(String(localized: "Vista previa de 30 s"))
                        .padding(.bottom, 6)
                }
                Text(nowPlaying.track.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(verbatim: "\(nowPlaying.track.artistName) — \(nowPlaying.track.albumTitle)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }
            .multilineTextAlignment(.center)

            VStack(spacing: 6) {
                ProgressTrack(progress: nowPlaying.progress)
                HStack {
                    Text(nowPlaying.elapsedSeconds.formattedAsTrackTime)
                    Spacer()
                    Text(verbatim: "-\(nowPlaying.remainingSeconds.formattedAsTrackTime)")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(Theme.tertiaryText)
            }

            controls(isPlaying: nowPlaying.isPlaying)
        }
        .padding(.vertical, 20)
    }

    private func controls(isPlaying: Bool) -> some View {
        HStack(spacing: 28) {
            AeroCircleButton(
                systemImage: "backward.fill",
                accessibilityLabel: String(localized: "Canción anterior"),
                action: { viewModel.skipToPrevious() }
            )
            AeroOrbButton(
                systemImage: isPlaying ? "pause.fill" : "play.fill",
                size: 70,
                accessibilityLabel: isPlaying ? String(localized: "Pausar") : String(localized: "Reproducir"),
                action: { viewModel.togglePlayPause() }
            )
            AeroCircleButton(
                systemImage: "forward.fill",
                accessibilityLabel: String(localized: "Canción siguiente"),
                action: { viewModel.skipToNext() }
            )
        }
    }
}

#Preview("Pista completa") {
    PlayerView(
        viewModel: PlayerViewModel(
            playback: SamplePlaybackController(
                nowPlaying: SampleData.tracks.first.map { SamplePlaybackController.sample($0) }
            ),
            library: SampleLibraryRepository()
        ),
        onMinimize: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Vista previa de 30 s") {
    PlayerView(
        viewModel: PlayerViewModel(
            playback: SamplePlaybackController(
                nowPlaying: SampleData.tracks.last.map { SamplePlaybackController.sample($0, isPreview: true) }
            ),
            library: SampleLibraryRepository()
        ),
        onMinimize: {}
    )
    .preferredColorScheme(.dark)
}
