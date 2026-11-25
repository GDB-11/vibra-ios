import ActivityKit
import DesignSystem
import SwiftUI
import WidgetKit
import WidgetShared

struct NowPlayingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NowPlayingAttributes.self) { context in
            LockScreenNowPlayingView(state: context.state)
                .activityBackgroundTint(Theme.ocean.opacity(0.85))
                .activitySystemActionForegroundColor(.white)
                .widgetURL(VibraDeepLink.player)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 10) {
                        NowPlayingHeader(state: context.state, artworkSize: 48)
                        ProgressTrack(progress: context.state.progress, height: 4)
                        TransportIcons(isPlaying: context.state.isPlaying)
                    }
                }
            } compactLeading: {
                CoverArtPlaceholder(hue: context.state.artworkHue, cornerRadius: 5)
                    .frame(width: 22, height: 22)
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .foregroundStyle(Theme.sky)
            } minimal: {
                Image(systemName: "waveform")
                    .foregroundStyle(Theme.sky)
            }
            .keylineTint(Theme.sky)
            .widgetURL(VibraDeepLink.player)
        }
    }
}

/// Tarjeta de la pantalla de bloqueo.
struct LockScreenNowPlayingView: View {
    let state: NowPlayingAttributes.ContentState

    var body: some View {
        VStack(spacing: 14) {
            NowPlayingHeader(state: state, artworkSize: 50)
            ProgressTrack(progress: state.progress, height: 4)
            TransportIcons(isPlaying: state.isPlaying)
        }
        .padding(16)
        .background { GlassSheen() }
    }
}

/// Anterior, reproducir o pausar y siguiente. Solo visuales.
struct TransportIcons: View {
    let isPlaying: Bool

    var body: some View {
        HStack {
            Image(systemName: "backward.fill")
            Spacer()
            PlayStateOrb(isPlaying: isPlaying, size: 40)
            Spacer()
            Image(systemName: "forward.fill")
        }
        .font(.title3)
        .foregroundStyle(.white)
        .padding(.horizontal, 28)
        .accessibilityHidden(true)
    }
}

#Preview("Pantalla de bloqueo", as: .content, using: NowPlayingAttributes()) {
    NowPlayingLiveActivity()
} contentStates: {
    NowPlayingSample.state
}
