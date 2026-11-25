import Domain
import Observation

public struct LibraryContent: Sendable {
    public let playlists: [Playlist]
    public let likedTracks: [Track]
    public let history: [Track]
}

@Observable
@MainActor
public final class LibraryViewModel {
    public enum Section: Hashable, Sendable {
        case playlists
        case likes
        case history
    }

    public var section: Section = .playlists
    public private(set) var state: LoadState<LibraryContent> = .idle

    private let repository: any LibraryRepository

    public init(repository: any LibraryRepository) {
        self.repository = repository
    }

    public func load() async {
        state = state.reloading
        do {
            let playlists = try await repository.playlists()
            let liked = try await repository.likedTracks()
            let history = try await repository.recentlyPlayed()
            state = .loaded(LibraryContent(playlists: playlists, likedTracks: liked, history: history))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }
}

public struct PlaylistDetailContent: Sendable {
    public let playlist: Playlist
    public let tracks: [Track]
}

@Observable
@MainActor
public final class PlaylistDetailViewModel {
    public private(set) var state: LoadState<PlaylistDetailContent> = .idle

    private let playlistID: String
    private let repository: any LibraryRepository

    public init(playlistID: String, repository: any LibraryRepository) {
        self.playlistID = playlistID
        self.repository = repository
    }

    public func load() async {
        state = state.reloading
        do {
            let playlist = try await repository.playlist(id: playlistID)
            let tracks = try await repository.tracks(playlistID: playlistID)
            state = .loaded(PlaylistDetailContent(playlist: playlist, tracks: tracks))
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }
}
