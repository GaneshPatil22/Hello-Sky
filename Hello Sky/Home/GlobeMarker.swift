import SkyCore
import SwiftUI

/// A person on the globe: their avatar in a bubble, with a name label under it.
///
/// A bubble rather than a dot because the globe is the main screen, and a face
/// is recognisable where a coloured point is not.
struct GlobeMarker: View {
    let person: Person
    let date: Date
    let isSelected: Bool
    let now: Date

    var body: some View {
        VStack(spacing: Layout.spacing) {
            bubble
            Text(person.name)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, Layout.labelPaddingX)
                .padding(.vertical, Layout.labelPaddingY)
                .background(.black.opacity(Layout.labelBackground), in: .capsule)
                .fixedSize()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(person.name), \(person.place.city)")
        .accessibilityValue(StatusDot.sentence(for: status))
        .accessibilityAddTraits(.isButton)
    }

    private var bubble: some View {
        Text(avatar)
            .font(.system(size: Layout.avatarSize))
            .frame(width: Layout.bubble, height: Layout.bubble)
            .background(.black.opacity(Layout.bubbleBackground), in: .circle)
            .overlay {
                Circle().strokeBorder(ringColour, lineWidth: isSelected ? Layout.selectedRing : Layout.ring)
            }
            // The status dot sits on the bubble, as it does on a contact badge,
            // so colour and face read as one thing.
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(StatusDot.colour(for: status))
                    .frame(width: Layout.dot, height: Layout.dot)
                    .overlay { Circle().strokeBorder(.black.opacity(Layout.dotRing), lineWidth: 1) }
            }
            .background { StatusRipple(status: status, diameter: Layout.bubble, now: now) }
            .shadow(color: .black.opacity(Layout.shadowOpacity), radius: Layout.shadow)
    }

    private var ringColour: Color {
        isSelected ? StatusDot.Palette.selected : .white.opacity(Layout.ringOpacity)
    }

    private var avatar: String {
        switch person.avatar {
        case .emoji(let emoji): emoji
        }
    }

    private var status: CallStatus {
        CallStatus.status(for: person, at: date)
    }
}

extension GlobeMarker {
    private enum Layout {
        static let bubble: Double = 38
        static let avatarSize: Double = 20
        static let bubbleBackground = 0.55
        static let ring: Double = 1.5
        static let selectedRing: Double = 2.5
        static let ringOpacity = 0.35
        static let dot: Double = 10
        static let dotRing = 0.6
        static let spacing: Double = 4
        static let labelPaddingX: Double = 7
        static let labelPaddingY: Double = 2
        static let labelBackground = 0.55
        static let shadow: Double = 6
        static let shadowOpacity = 0.5
    }
}
