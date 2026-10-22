import SwiftUI

/// The app's one surface style: a dark pane with a hairline edge.
///
/// Lighter than a full glass effect on purpose. These panels sit over a live
/// sky and a lit globe, and the colour behind them is the point; a heavy
/// material turns that into grey.
struct Panel: ViewModifier {
    var cornerRadius: Double = Layout.cornerRadius
    var isHighlighted = false

    func body(content: Content) -> some View {
        content
            .background(.black.opacity(Layout.fill), in: .rect(cornerRadius: cornerRadius))
            .background(.ultraThinMaterial.opacity(Layout.material), in: .rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        .white.opacity(isHighlighted ? Layout.edgeHighlighted : Layout.edge),
                        lineWidth: Layout.edgeWidth
                    )
            }
    }
}

extension View {
    /// Puts this content on the app's standard pane.
    func panel(cornerRadius: Double = Panel.Layout.cornerRadius, isHighlighted: Bool = false) -> some View {
        modifier(Panel(cornerRadius: cornerRadius, isHighlighted: isHighlighted))
    }
}

extension Panel {
    enum Layout {
        static let cornerRadius: Double = 22
        static let fill = 0.34
        /// Just enough material to separate the pane from the sky behind it.
        static let material = 0.5
        static let edge = 0.10
        static let edgeHighlighted = 0.30
        static let edgeWidth: Double = 1
    }
}
