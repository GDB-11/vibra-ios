import Foundation

/// Error de los repositorios de ejemplo cuando no existe el elemento pedido.
public struct SampleNotFoundError: Error, Sendable {
    public init() {}
}

// Las lecturas devuelven datos fijos y las escrituras no hacen nada a propósito:
// esta fase solo implementa pantallas y navegación.

public struct SampleAuthRepository: AuthRepository {
    public init() {}

    public func signIn(email: String, password: String) async throws {}
    public func register(email: String, password: String) async throws {}
    public func signOut() async throws {}
    public func currentUser() async throws -> UserProfile { SampleData.user }
}

public struct SampleCatalogRepository: CatalogRepository {
    public init() {}

    public func featuredArtist() async throws -> Artist { SampleData.artist }

    public func artist(id: String) async throws -> Artist {
        guard id == SampleData.artist.id else { throw SampleNotFoundError() }
        return SampleData.artist
    }

    public func albums(cursor: String?) async throws -> Page<Album> {
        Page(items: SampleData.albums)
    }

    public func albums(artistID: String, cursor: String?) async throws -> Page<Album> {
        Page(items: SampleData.albums.filter { $0.artistID == artistID })
    }

    public func album(id: String) async throws -> Album {
        guard let album = SampleData.albums.first(where: { $0.id == id }) else { throw SampleNotFoundError() }
        return album
    }

    public func tracks(albumID: String) async throws -> [Track] {
        SampleData.tracks.filter { $0.albumID == albumID }
    }
}

public struct SampleSearchRepository: SearchRepository {
    private let isEmpty: Bool

    public init(isEmpty: Bool = false) {
        self.isEmpty = isEmpty
    }

    /// Ignora la consulta: la lista es fija.
    public func searchTracks(query: String, cursor: String?) async throws -> Page<Track> {
        let results = [0, 2, 5, 9, 13, 17, 21, 23].compactMap { index in
            SampleData.tracks.indices.contains(index) ? SampleData.tracks[index] : nil
        }
        return Page(items: isEmpty ? [] : results)
    }
}

public struct SampleLibraryRepository: LibraryRepository {
    private let isEmpty: Bool

    public init(isEmpty: Bool = false) {
        self.isEmpty = isEmpty
    }

    public func playlists() async throws -> [Playlist] { isEmpty ? [] : SampleData.playlists }

    public func playlist(id: String) async throws -> Playlist {
        guard let playlist = SampleData.playlists.first(where: { $0.id == id }) else { throw SampleNotFoundError() }
        return playlist
    }

    public func tracks(playlistID: String) async throws -> [Track] {
        isEmpty ? [] : SampleData.playlistTracks(id: playlistID)
    }

    public func likedTracks() async throws -> [Track] { isEmpty ? [] : SampleData.likedTracks }
    public func recentlyPlayed() async throws -> [Track] { isEmpty ? [] : SampleData.recentlyPlayed }
    public func setTrackLiked(_ isLiked: Bool, trackID: String) async throws {}
    public func setAlbumLiked(_ isLiked: Bool, albumID: String) async throws {}
}

public struct SampleStreamingRepository: StreamingRepository {
    public init() {}

    public func streamAccess(trackID: String) async throws -> StreamAccess {
        guard let track = SampleData.tracks.first(where: { $0.id == trackID }),
              let url = URL(string: "https://example.invalid/audio")
        else { throw SampleNotFoundError() }
        return track.isLocked ? .locked(previewURL: url) : .granted(url: url)
    }
}

public struct SampleBillingRepository: BillingRepository {
    public init() {}

    public func entitlements() async throws -> Entitlements { SampleData.entitlements }
    public func plans() async throws -> [Plan] { SampleData.plans }
    public func subscribe(toPlan id: Plan.ID) async throws {}
    public func purchaseTrack(id: String) async throws {}
    public func purchaseAlbum(id: String) async throws {}
    public func restorePurchases() async throws {}
}
