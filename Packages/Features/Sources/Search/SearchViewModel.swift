import Domain
import Observation

@Observable
@MainActor
public final class SearchViewModel {
    public var query = ""
    public private(set) var state: LoadState<[Track]> = .idle
    /// Consulta que produjo los resultados visibles.
    public private(set) var searchedQuery = ""

    private let repository: any SearchRepository

    public init(repository: any SearchRepository) {
        self.repository = repository
    }

    public func search() async {
        let submitted = self.query
        state = state.reloading
        do {
            let page = try await repository.searchTracks(query: submitted, cursor: nil)
            searchedQuery = submitted
            state = .loaded(page.items)
        } catch is CancellationError {
            return
        } catch {
            state = .failed
        }
    }
}
