import SkyUI
import SwiftUI

/// Picking a look, shown as the three globes themselves.
///
/// Swatches rather than names: the choice is about how the Earth and the sky
/// look, so the sample is the honest label.
struct LookSheet: View {
    @Bindable var settings: AppSettings
    @Environment(\.themeRegistry) private var registry
    @Environment(\.dismiss) private var dismiss

    static let preferredHeight: Double = 230

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text("Look")
                .font(.title2.weight(.bold))
            HStack(spacing: Layout.swatchSpacing) {
                ForEach(registry.themes) { theme in
                    swatch(for: theme)
                }
            }
        }
        .padding(Layout.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func swatch(for theme: Theme) -> some View {
        let isChosen = theme.id == settings.themeID
        return Button {
            settings.themeID = theme.id
            dismiss()
        } label: {
            VStack(spacing: Layout.labelSpacing) {
                Circle()
                    .fill(.radialGradient(
                        Gradient(colors: [
                            theme.globe.oceanLit.color,
                            theme.globe.oceanDeep.color,
                        ]),
                        center: .init(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: Layout.swatch * 0.8
                    ))
                    .frame(width: Layout.swatch, height: Layout.swatch)
                Text(theme.name)
                    .font(.subheadline.weight(isChosen ? .semibold : .regular))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.swatchPadding)
        }
        .buttonStyle(.plain)
        .panel(cornerRadius: Layout.corner, isHighlighted: isChosen)
        .accessibilityAddTraits(isChosen ? [.isButton, .isSelected] : .isButton)
    }
}

extension LookSheet {
    private enum Layout {
        static let padding: Double = 24
        static let spacing: Double = 18
        static let swatchSpacing: Double = 12
        static let swatch: Double = 60
        static let swatchPadding: Double = 14
        static let labelSpacing: Double = 10
        static let corner: Double = 18
    }
}
