import DesignSystem
import Domain
import SwiftUI

public struct AlbumDetailView: View {
    @State private var viewModel: AlbumDetailViewModel
    private let onSelectTrack: (Track) -> Void
    private let onBuyAlbum: (Album) -> Void

    public init(
        viewModel: AlbumDetailViewModel,
        onSelectTrack: @escaping (Track) -> Void,
        onBuyAlbum: @escaping (Album) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectTrack = onSelectTrack
        self.onBuyAlbum = onBuyAlbum
    }

    public var body: some View {
        AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
            await viewModel.load()
        } content: { content in
            ScrollView {
                VStack(spacing: 16) {
                    header(content.album)
                    actions(content)
                    LazyVStack(spacing: 1) {
                        ForEach(content.tracks) { track in
                            TrackRow(
                                leading: .number(track.number),
                                title: track.title,
                                duration: track.durationSeconds.formattedAsTrackTime,
                                isLocked: track.isLocked
                            ) {
                                onSelectTrack(track)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
        }
        .background {
            AeroBackground(tint: viewModel.state.value.map { Color.artworkTint(hue: $0.album.artworkHue) } ?? Theme.glow)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.likeAlbum() }
                } label: {
                    Image(systemName: "heart")
                }
                .accessibilityLabel(String(localized: "Me gusta"))
            }
        }
        .task { await viewModel.load() }
    }

    private func header(_ album: Album) -> some View {
        VStack(spacing: 14) {
            CoverArtPlaceholder(
                hue: album.artworkHue,
                cornerRadius: 18,
                caption: String(localized: "PORTADA DEL ÁLBUM\n\(album.title)")
            )
            .frame(width: 180, height: 180)
            .shadow(color: Theme.shadow.opacity(0.5), radius: 17, y: 12)

            VStack(spacing: 4) {
                Text(album.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(verbatim: "\(album.artistName) · \(album.year) · \(String(localized: "\(album.trackCount) canciones"))")
                    .font(.footnote)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func actions(_ content: AlbumDetailContent) -> some View {
        HStack(spacing: 10) {
            Button {
                if let first = content.tracks.first {
                    onSelectTrack(first)
                }
            } label: {
                Label(String(localized: "Reproducir"), systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(AeroPrimaryButtonStyle())

            if content.album.isLocked {
                Button {
                    onBuyAlbum(content.album)
                } label: {
                    Text(String(localized: "Comprar \(content.album.price.formatted)"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AeroSecondaryButtonStyle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        AlbumDetailView(
            viewModel: AlbumDetailViewModel(
                albumID: "rof",
                catalog: SampleCatalogRepository(),
                library: SampleLibraryRepository()
            ),
            onSelectTrack: { _ in },
            onBuyAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
