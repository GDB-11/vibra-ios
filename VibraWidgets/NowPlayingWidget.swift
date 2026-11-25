import DesignSystem
import SwiftUI
import WidgetKit
import WidgetShared

struct NowPlayingEntry: TimelineEntry {
    let date: Date
    let state: NowPlayingAttributes.ContentState
}

/// Entrega siempre la misma entrada de ejemplo.
struct NowPlayingProvider: TimelineProvider {
    func placeholder(in context: Context) -> NowPlayingEntry {
        entry
    }

    func getSnapshot(in context: Context, completion: @escaping (NowPlayingEntry) -> Void) {
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NowPlayingEntry>) -> Void) {
        completion(Timeline(entries: [entry], policy: .never))
    }

    private var entry: NowPlayingEntry {
        NowPlayingEntry(date: .now, state: NowPlayingSample.state)
    }
}

struct NowPlayingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NowPlayingWidget", provider: NowPlayingProvider()) { entry in
            NowPlayingWidgetView(entry: entry)
        }
        .configurationDisplayName(String(localized: "Reproduciendo ahora"))
        .description(String(localized: "La canción que suena en Vibra."))
        .supportedFamilies([.systemMedium])
    }
}

struct NowPlayingWidgetView: View {
    let entry: NowPlayingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Reproduciendo ahora"))
                .font(.caption2.bold())
                .foregroundStyle(Theme.tertiaryText)
            HStack(spacing: 12) {
                NowPlayingHeader(state: entry.state, artworkSize: 60)
                PlayStateOrb(isPlaying: entry.state.isPlaying, size: 38)
            }
            ProgressTrack(progress: entry.state.progress, height: 4)
        }
        .containerBackground(for: .widget) {
            ZStack {
                AeroBackground()
                GlassSheen()
            }
        }
        .widgetURL(VibraDeepLink.player)
    }
}

#Preview(as: .systemMedium) {
    NowPlayingWidget()
} timeline: {
    NowPlayingEntry(date: .now, state: NowPlayingSample.state)
}
