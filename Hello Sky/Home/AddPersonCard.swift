import SwiftUI

/// The dashed card at the end of the row.
///
/// Also offered in the title bar, because once someone follows eight people
/// this one has scrolled well out of sight.
struct AddPersonCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Layout.spacing) {
                Image(systemName: "plus")
                    .font(.title3.weight(.medium))
                Text("Add")
                    .font(.subheadline)
            }
            .foregroundStyle(.white.opacity(Layout.foreground))
            .frame(width: Layout.width, height: PersonChip.Layout.height)
        }
        .buttonStyle(.plain)
        .overlay {
            RoundedRectangle(cornerRadius: PersonChip.Layout.cornerRadius)
                .strokeBorder(
                    .white.opacity(Layout.edge),
                    style: StrokeStyle(lineWidth: Layout.edgeWidth, dash: Layout.dash)
                )
        }
        .accessibilityLabel("Add a person")
    }
}

extension AddPersonCard {
    private enum Layout {
        static let width: Double = 116
        static let spacing: Double = 8
        static let foreground = 0.75
        static let edge = 0.22
        static let edgeWidth: Double = 1.2
        static let dash: [CGFloat] = [5, 4]
    }
}
