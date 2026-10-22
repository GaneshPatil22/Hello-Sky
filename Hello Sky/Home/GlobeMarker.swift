import SkyCore
import SwiftUI

/// One city on the globe: a dot coloured by status, with the name beside it.
struct GlobeMarker: View {
    let person: Person
    let date: Date
    let isSelected: Bool

    var body: some View {
        VStack(spacing: Layout.spacing) {
            ZStack {
                Circle()
                    .fill(StatusDot.colour(for: status))
                    .frame(width: Layout.dot, height: Layout.dot)
                if isSelected {
                    Circle()
                        .stroke(.white, lineWidth: Layout.ringWidth)
                        .frame(width: Layout.ring, height: Layout.ring)
                }
            }
            Text(person.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white)
                .shadow(radius: Layout.shadow)
                .fixedSize()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(person.name), \(person.place.city)")
        .accessibilityValue(StatusDot.sentence(for: status))
        .accessibilityAddTraits(.isButton)
    }

    private var status: CallStatus {
        CallStatus.status(for: person, at: date)
    }
}

extension GlobeMarker {
    private enum Layout {
        static let dot: Double = 10
        static let ring: Double = 18
        static let ringWidth: Double = 1.5
        static let spacing: Double = 3
        static let shadow: Double = 3
    }
}
