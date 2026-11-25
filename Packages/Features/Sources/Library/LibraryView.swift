import DesignSystem
import Domain
import SwiftUI

public struct LibraryView: View {
    @State private var viewModel: LibraryViewModel
    private let onSelectPlaylist: (Playlist) -> Void
    private let onSelectTrack: (Track) -> Void

    public init(
        viewModel: LibraryViewModel,
        onSelectPlaylist: @escaping (Playlist) -> Void,
        onSelectTrack: @escaping (Track) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectPlaylist = onSelectPlaylist
        self.onSelectTrack = onSelectTrack
    }

    public var body: some View {
        VStack(spacing: 12) {
            AeroSegmentedControl(
                segments: [
                    AeroSegment(LibraryViewModel.Section.playlists, title: String(localized: "Listas")),
                    AeroSegment(LibraryViewModel.Section.likes, title: String(localized: "Me gusta")),
                    AeroSegment(LibraryViewModel.Section.history, title: String(localized: "Historial"))
                ],
                selection: $viewModel.section
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)

            AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
                await viewModel.load()
            } content: { content in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        switch viewModel.section {
                        case .playlists:
                            playlistList(content.playlists)
                        case .likes:
                            trackList(
                                content.likedTracks,
                                emptyMessage: String(localized: "Toca el corazón en una canción para guardarla aquí.")
                            )
                        case .history:
                            trackList(content.history, emptyMessage: String(localized: "Aún no has reproducido nada."))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .background { AeroBackground() }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private func playlistList(_ playlists: [Playlist]) -> some View {
        ForEach(playlists) { playlist in
            Button {
                onSelectPlaylist(playlist)
            } label: {
                HStack(spacing: 12) {
                    CoverArtPlaceholder(hue: playlist.artworkHue, cornerRadius: 11)
                        .frame(width: 52, height: 52)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(playlist.name)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text(String(localized: "\(playlist.trackCount) canciones"))
                            .font(.caption)
                            .foregroundStyle(Theme.tertiaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.bold())
                        .foregroundStyle(Theme.tertiaryText)
                }
                .padding(10)
                .contentShape(Rectangle())
                .aeroCard(.subtle, cornerRadius: 15)
            }
            .buttonStyle(.plain)
        }
        if playlists.isEmpty {
            EmptyStateView(String(localized: "Aún no tienes listas."))
        }
    }

    @ViewBuilder
    private func trackList(_ tracks: [Track], emptyMessage: String) -> some View {
        ForEach(tracks) { track in
            TrackRow(
                leading: .artwork(hue: track.artworkHue),
                title: track.title,
                subtitle: track.albumTitle,
                isLocked: track.isLocked
            ) {
                onSelectTrack(track)
            }
        }
        if tracks.isEmpty {
            EmptyStateView(emptyMessage)
        }
    }
}

#Preview("Con contenido") {
    LibraryView(
        viewModel: LibraryViewModel(repository: SampleLibraryRepository()),
        onSelectPlaylist: { _ in },
        onSelectTrack: { _ in }
    )
    .preferredColorScheme(.dark)
}

#Preview("Vacía") {
    LibraryView(
        viewModel: LibraryViewModel(repository: SampleLibraryRepository(isEmpty: true)),
        onSelectPlaylist: { _ in },
        onSelectTrack: { _ in }
    )
    .preferredColorScheme(.dark)
}
