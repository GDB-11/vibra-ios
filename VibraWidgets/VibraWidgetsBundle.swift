import SwiftUI
import WidgetKit

@main
struct VibraWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NowPlayingWidget()
        NowPlayingLiveActivity()
    }
}
