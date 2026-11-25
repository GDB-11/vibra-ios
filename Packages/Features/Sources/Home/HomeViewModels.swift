import Domain
import Observation

public struct HomeContent: Sendable {
    public let featuredArtist: Artist
    public let albums: [Album]
    public let recentlyPlayed: [Track]
}

@Observable
@MainActor
public final class HomeViewModel {
    public private(set) var state: LoadState<HomeContent> = .idle

    private let catalog: any CatalogRepository
    private let library: any LibraryRepository

    public init(catalog: any CatalogRepository, library: any LibraryRepository) {
        self.catalog = catalog
        self.library = library
    }

    public func load() async {
        state = state.reloading
        do {
            let artist = try await catalog.featuredArtist()
            let albums = try await catalog.albums(cursor: nil)
            let recent = try await library.recentlyPlayed()
            state = .loaded(HomeContent(featuredArtist: artist, albums: albums.items, recentlyPlayed: recent))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }
}

public struct AlbumDetailContent: Sendable {
    public let album: Album
    public let tracks: [Track]
}

@Observable
@MainActor
public final class AlbumDetailViewModel {
    public private(set) var state: LoadState<AlbumDetailContent> = .idle

    private let albumID: String
    private let catalog: any CatalogRepository
    private let library: any LibraryRepository

    public init(albumID: String, catalog: any CatalogRepository, library: any LibraryRepository) {
        self.albumID = albumID
        self.catalog = catalog
        self.library = library
    }

    public func load() async {
        state = state.reloading
        do {
            let album = try await catalog.album(id: albumID)
            let tracks = try await catalog.tracks(albumID: albumID)
            state = .loaded(AlbumDetailContent(album: album, tracks: tracks))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }

    /// El estado del corazón llegará del backend; por ahora solo se envía la intención.
    public func likeAlbum() async {
        // Con datos de ejemplo no cambia nada. Falta mostrar el error cuando exista el backend.
        try? await library.setAlbumLiked(true, albumID: albumID)
    }
}

public struct ArtistContent: Sendable {
    public let artist: Artist
    public let albums: [Album]
}

@Observable
@MainActor
public final class ArtistViewModel {
    public private(set) var state: LoadState<ArtistContent> = .idle

    private let artistID: String
    private let catalog: any CatalogRepository

    public init(artistID: String, catalog: any CatalogRepository) {
        self.artistID = artistID
        self.catalog = catalog
    }

    public func load() async {
        state = state.reloading
        do {
            let artist = try await catalog.artist(id: artistID)
            let albums = try await catalog.albums(artistID: artistID, cursor: nil)
            state = .loaded(ArtistContent(artist: artist, albums: albums.items))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }
}
