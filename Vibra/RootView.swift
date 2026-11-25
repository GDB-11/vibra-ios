import SwiftUI

/// Vista raíz provisional hasta que existan las funcionalidades.
struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(String(localized: "Vibra"))
                .font(.largeTitle.bold())
            Text(String(localized: "Todo el catálogo, o solo lo que amas."))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    RootView()
}
