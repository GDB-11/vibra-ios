import DesignSystem
import Domain
import SwiftUI

public struct PlaylistDetailView: View {
    @State private var viewModel: PlaylistDetailViewModel
    private let onSelectTrack: (Track) -> Void

    public init(viewModel: PlaylistDetailViewModel, onSelectTrack: @escaping (Track) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectTrack = onSelectTrack
    }

    public var body: some View {
        AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
            await viewModel.load()
        } content: { content in
            ScrollView {
                VStack(spacing: 16) {
                    CoverArtPlaceholder(hue: content.playlist.artworkHue, cornerRadius: 18)
                        .frame(width: 170, height: 170)
                        .shadow(color: Theme.shadow.opacity(0.5), radius: 17, y: 12)

                    VStack(spacing: 4) {
                        Text(content.playlist.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Text(String(localized: "\(content.playlist.trackCount) canciones"))
                            .font(.footnote)
                            .foregroundStyle(Theme.secondaryText)
                    }

                    if let first = content.tracks.first {
                        Button {
                            onSelectTrack(first)
                        } label: {
                            Label(String(localized: "Reproducir"), systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(AeroPrimaryButtonStyle())
                    }

                    LazyVStack(spacing: 1) {
                        ForEach(content.tracks) { track in
                            TrackRow(
                                leading: .artwork(hue: track.artworkHue),
                                title: track.title,
                                subtitle: track.albumTitle,
                                duration: track.durationSeconds.formattedAsTrackTime,
                                isLocked: track.isLocked
                            ) {
                                onSelectTrack(track)
                            }
                        }
                        if content.tracks.isEmpty {
                            EmptyStateView(String(localized: "Esta lista está vacía."))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
        }
        .background {
            AeroBackground(tint: viewModel.state.value.map { Color.artworkTint(hue: $0.playlist.artworkHue) } ?? Theme.glow)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        PlaylistDetailView(
            viewModel: PlaylistDetailViewModel(playlistID: "indie", repository: SampleLibraryRepository()),
            onSelectTrack: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
