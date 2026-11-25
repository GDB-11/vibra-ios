import DesignSystem
import Domain
import SwiftUI

public struct ArtistView: View {
    @State private var viewModel: ArtistViewModel
    private let onSelectAlbum: (Album) -> Void

    public init(viewModel: ArtistViewModel, onSelectAlbum: @escaping (Album) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectAlbum = onSelectAlbum
    }

    public var body: some View {
        AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
            await viewModel.load()
        } content: { content in
            ScrollView {
                VStack(spacing: 22) {
                    header(content.artist)
                    VStack(spacing: 10) {
                        SectionTitle(String(localized: "Álbumes"))
                        AlbumGrid(albums: content.albums, onSelect: onSelectAlbum)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .background {
            AeroBackground(tint: viewModel.state.value.map { Color.artworkTint(hue: $0.artist.artworkHue) } ?? Theme.glow)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func header(_ artist: Artist) -> some View {
        VStack(spacing: 12) {
            CoverArtPlaceholder(hue: artist.artworkHue, cornerRadius: 70)
                .frame(width: 140, height: 140)
                .shadow(color: Theme.shadow.opacity(0.5), radius: 17, y: 12)
            VStack(spacing: 4) {
                Text(artist.name)
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text(String(localized: "\(artist.albumCount) álbumes · \(artist.genre), \(artist.origin)"))
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .aeroCard(cornerRadius: 22)
    }
}

#Preview {
    NavigationStack {
        ArtistView(
            viewModel: ArtistViewModel(artistID: SampleData.artist.id, catalog: SampleCatalogRepository()),
            onSelectAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
