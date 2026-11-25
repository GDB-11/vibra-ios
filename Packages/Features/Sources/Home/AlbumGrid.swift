import DesignSystem
import Domain
import SwiftUI

/// Cuadrícula de álbumes compartida por el inicio y la página de artista.
struct AlbumGrid: View {
    let albums: [Album]
    let onSelect: (Album) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14, alignment: .top)], spacing: 16) {
            ForEach(albums) { album in
                Button {
                    onSelect(album)
                } label: {
                    VStack(alignment: .leading, spacing: 7) {
                        CoverArtPlaceholder(
                            hue: album.artworkHue,
                            caption: String(localized: "PORTADA\n\(album.title)")
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topTrailing) {
                            if album.isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(6)
                                    .background(Theme.shadow.opacity(0.65), in: RoundedRectangle(cornerRadius: 6))
                                    .padding(6)
                                    .accessibilityLabel(String(localized: "Bloqueado"))
                            }
                        }
                        .shadow(color: Theme.shadow.opacity(0.4), radius: 9, y: 6)

                        Text(album.title)
                            .font(.footnote.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Text(String(album.year))
                            .font(.caption2)
                            .foregroundStyle(Theme.tertiaryText)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
