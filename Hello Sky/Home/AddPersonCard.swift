import SwiftUI

/// The dashed card at the end of the row.
///
/// Also offered in the title bar, because once someone follows eight people
/// this one has scrolled well out of sight.
struct AddPersonCard: View {
    let isFull: Bool
    let limit: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Layout.spacing) {
                Image(systemName: isFull ? "person.2.slash" : "plus")
                    .font(.title3.weight(.medium))
                Text(isFull ? "Full" : "Add")
                    .font(.subheadline)
                if isFull {
                    // Says why rather than leaving a dead button to puzzle over.
                    Text("\(limit) is the most")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(Layout.captionOpacity))
                        .multilineTextAlignment(.center)
                }
            }
            .foregroundStyle(.white.opacity(isFull ? Layout.fullForeground : Layout.foreground))
            .frame(width: Layout.width, height: PersonChip.Layout.height)
        }
        .buttonStyle(.plain)
        .disabled(isFull)
        .overlay {
            RoundedRectangle(cornerRadius: PersonChip.Layout.cornerRadius)
                .strokeBorder(
                    .white.opacity(Layout.edge),
                    style: StrokeStyle(lineWidth: Layout.edgeWidth, dash: Layout.dash)
                )
        }
        .accessibilityLabel(isFull ? "List full" : "Add a person")
        .accessibilityHint(isFull ? "You can follow up to \(limit) people. Remove someone first." : "")
    }
}

extension AddPersonCard {
    private enum Layout {
        static let width: Double = 116
        static let spacing: Double = 6
        static let foreground = 0.75
        static let fullForeground = 0.45
        static let captionOpacity = 0.5
        static let edge = 0.22
        static let edgeWidth: Double = 1.2
        static let dash: [CGFloat] = [5, 4]
    }
}
