import DesignSystem
import Domain
import SwiftUI

public struct SearchView: View {
    @State private var viewModel: SearchViewModel
    private let onSelectTrack: (Track) -> Void

    public init(viewModel: SearchViewModel, onSelectTrack: @escaping (Track) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSelectTrack = onSelectTrack
    }

    public var body: some View {
        VStack(spacing: 12) {
            AeroTextField(
                String(localized: "Artistas, álbumes o canciones"),
                text: $viewModel.query,
                isCapsule: true
            )
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit {
                Task { await viewModel.search() }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            AsyncContentView(value: viewModel.state.value, hasFailed: viewModel.state.hasFailed) {
                await viewModel.search()
            } content: { tracks in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(tracks) { track in
                            TrackRow(
                                leading: .artwork(hue: track.artworkHue),
                                title: track.title,
                                subtitle: "\(track.artistName) · \(track.albumTitle)",
                                isLocked: track.isLocked
                            ) {
                                onSelectTrack(track)
                            }
                        }
                        if tracks.isEmpty {
                            EmptyStateView(emptyMessage)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .frame(maxHeight: .infinity)
        }
        .background { AeroBackground() }
        .task { await viewModel.search() }
    }

    private var emptyMessage: String {
        viewModel.searchedQuery.isEmpty
            ? String(localized: "Sin resultados")
            : String(localized: "Sin resultados para \"\(viewModel.searchedQuery)\"")
    }
}

#Preview("Resultados") {
    SearchView(viewModel: SearchViewModel(repository: SampleSearchRepository()), onSelectTrack: { _ in })
        .preferredColorScheme(.dark)
}

#Preview("Sin resultados") {
    SearchView(viewModel: SearchViewModel(repository: SampleSearchRepository(isEmpty: true)), onSelectTrack: { _ in })
        .preferredColorScheme(.dark)
}
