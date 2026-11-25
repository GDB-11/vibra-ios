import ActivityKit
import Domain
import WidgetShared

/// Refleja en la Live Activity lo que la app tiene en reproducción. Se actualiza solo en local.
enum LiveActivityController {
    static func sync(with nowPlaying: NowPlaying?) async {
        guard let nowPlaying else {
            await endAll()
            return
        }
        await show(
            NowPlayingAttributes.ContentState(
                title: nowPlaying.track.title,
                artistName: nowPlaying.track.artistName,
                albumTitle: nowPlaying.track.albumTitle,
                artworkHue: nowPlaying.track.artworkHue,
                progress: nowPlaying.progress,
                isPlaying: nowPlaying.isPlaying
            )
        )
    }

    // `@concurrent` mantiene cada `Activity`, que no es `Sendable`, fuera del actor principal.
    @concurrent
    private static func show(_ state: NowPlayingAttributes.ContentState) async {
        let content = ActivityContent(state: state, staleDate: nil)
        let activities = Activity<NowPlayingAttributes>.activities

        if activities.isEmpty {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
            // La Live Activity es opcional: si el sistema la rechaza, la app sigue igual.
            _ = try? Activity.request(attributes: NowPlayingAttributes(), content: content, pushType: nil)
        } else {
            for activity in activities {
                await activity.update(content)
            }
        }
    }

    @concurrent
    private static func endAll() async {
        for activity in Activity<NowPlayingAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
