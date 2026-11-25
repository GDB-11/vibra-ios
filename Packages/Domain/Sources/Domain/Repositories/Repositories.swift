// Contratos que las funcionalidades consumen. Las implementaciones reales irán en Networking
// (sobre el cliente generado) y las de ejemplo están en `Samples`.

public protocol AuthRepository: Sendable {
    func signIn(email: String, password: String) async throws
    func register(email: String, password: String) async throws
    func signOut() async throws
    func currentUser() async throws -> UserProfile
}

public protocol CatalogRepository: Sendable {
    func featuredArtist() async throws -> Artist
    func artist(id: String) async throws -> Artist
    func albums(cursor: String?) async throws -> Page<Album>
    func albums(artistID: String, cursor: String?) async throws -> Page<Album>
    func album(id: String) async throws -> Album
    func tracks(albumID: String) async throws -> [Track]
}

public protocol SearchRepository: Sendable {
    func searchTracks(query: String, cursor: String?) async throws -> Page<Track>
}

public protocol LibraryRepository: Sendable {
    func playlists() async throws -> [Playlist]
    func playlist(id: String) async throws -> Playlist
    func tracks(playlistID: String) async throws -> [Track]
    func likedTracks() async throws -> [Track]
    func recentlyPlayed() async throws -> [Track]
    func setTrackLiked(_ isLiked: Bool, trackID: String) async throws
    func setAlbumLiked(_ isLiked: Bool, albumID: String) async throws
}

public protocol StreamingRepository: Sendable {
    func streamAccess(trackID: String) async throws -> StreamAccess
}

public protocol BillingRepository: Sendable {
    func entitlements() async throws -> Entitlements
    func plans() async throws -> [Plan]
    func subscribe(to plan: Plan.Code) async throws
    func purchaseTrack(id: String) async throws
    func restorePurchases() async throws
}
