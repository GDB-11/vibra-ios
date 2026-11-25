import DesignSystem
import Domain
import SwiftUI

public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    private let onSelectArtist: (Artist) -> Void
    private let onSelectAlbum: (Album) -> Void
    private let onSelectTrack: (Track) -> Void

    public init(
        viewModel: HomeViewModel,
        onSelectArtist: @escaping (Artist) -> Void,
        onSelectAlbum: @escaping (Album) -> Void,
        onSelectTrack: @escaping (Track) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectArtist = onSelectArtist
        self.onSelectAlbum = onSelectAlbum
        self.onSelectTrack = onSelectTrack
    }

    public var body: some View {
        AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
            await viewModel.load()
        } content: { content in
            ScrollView {
                VStack(spacing: 22) {
                    featuredCard(content.featuredArtist)

                    VStack(spacing: 10) {
                        SectionTitle(String(localized: "Álbumes"))
                        AlbumGrid(albums: content.albums, onSelect: onSelectAlbum)
                    }

                    if !content.recentlyPlayed.isEmpty {
                        VStack(spacing: 6) {
                            SectionTitle(String(localized: "Reproducido recientemente"))
                            ForEach(content.recentlyPlayed) { track in
                                TrackRow(
                                    leading: .artwork(hue: track.artworkHue),
                                    title: track.title,
                                    subtitle: track.albumTitle,
                                    isLocked: track.isLocked
                                ) {
                                    onSelectTrack(track)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .background { AeroBackground() }
        .task { await viewModel.load() }
    }

    private func featuredCard(_ artist: Artist) -> some View {
        Button {
            onSelectArtist(artist)
        } label: {
            VStack(alignment: .leading, spacing: 5) {
                Text(String(localized: "Destacado"))
                    .font(.caption2.bold())
                    .textCase(.uppercase)
                    .kerning(1)
                    .foregroundStyle(Theme.secondaryText)
                Text(artist.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(String(localized: "\(artist.albumCount) álbumes · \(artist.genre), \(artist.origin)"))
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .contentShape(Rectangle())
            .aeroCard(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(catalog: SampleCatalogRepository(), library: SampleLibraryRepository()),
        onSelectArtist: { _ in },
        onSelectAlbum: { _ in },
        onSelectTrack: { _ in }
    )
    .preferredColorScheme(.dark)
}
