import DesignSystem
import SwiftUI

/// Barra de pestañas de cristal Aero.
struct AeroTabBar: View {
    @Binding var selection: AppTab
    let onReselect: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = selection == tab
                Button {
                    if isSelected {
                        onReselect(tab)
                    } else {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(isSelected ? Theme.navy : .white.opacity(0.7))
                            .frame(width: 40, height: 26)
                            .background {
                                if isSelected {
                                    Capsule().fill(Theme.orb)
                                }
                            }
                        Text(tab.title)
                            .font(.caption2.bold())
                            .foregroundStyle(isSelected ? .white : .white.opacity(0.65))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .aeroCard(cornerRadius: 26)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}
