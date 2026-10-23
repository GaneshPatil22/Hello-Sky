import SwiftUI

/// The bar along the bottom.
///
/// Drawn rather than taken from `TabView`, whose bar on this release is a
/// floating capsule with a selected pill. The design calls for a flat bar with
/// a hairline above it, which no amount of styling gets from the system one.
struct AppTabBar: View {
    @Binding var selection: HomeView.Section

    /// How much room to keep clear above the bar's own safe area.
    static let height: Double = 58

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeView.Section.allCases, id: \.self) { section in
                item(for: section)
            }
        }
        .frame(height: Self.height)
        .frame(maxWidth: .infinity)
        .background(alignment: .top) {
            Rectangle()
                .fill(.white.opacity(Layout.hairline))
                .frame(height: Layout.hairlineWidth)
        }
        .background(.black.opacity(Layout.fill))
        .background(.ultraThinMaterial.opacity(Layout.material))
    }

    private func item(for section: HomeView.Section) -> some View {
        let isSelected = section == selection
        return Button {
            selection = section
        } label: {
            VStack(spacing: Layout.spacing) {
                Image(systemName: section.symbol)
                    .font(.system(size: Layout.icon, weight: .regular))
                Text(section.title)
                    .font(.caption2)
            }
            .foregroundStyle(.white.opacity(isSelected ? 1 : Layout.resting))
            .frame(maxWidth: .infinity)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(section.title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

extension AppTabBar {
    private enum Layout {
        static let icon: Double = 21
        static let spacing: Double = 5
        static let resting = 0.45
        static let hairline = 0.08
        static let hairlineWidth: Double = 1
        static let fill = 0.55
        static let material = 0.7
    }
}
