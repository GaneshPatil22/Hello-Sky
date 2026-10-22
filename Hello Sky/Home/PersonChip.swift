import SkyCore
import SwiftUI

/// One person in the row under the globe: who, what time it is there, and
/// whether to call.
struct PersonChip: View {
    let person: Person
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.spacing) {
                HStack(spacing: Layout.avatarGap) {
                    Text(avatar)
                        .font(.title3)
                    Text(person.name)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                }
                Text(timeText)
                    .font(.title3.weight(.light))
                    .monospacedDigit()
                HStack(spacing: Layout.dotGap) {
                    StatusDot(status: status)
                    Text(StatusDot.label(for: status))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(width: Layout.width, alignment: .leading)
            .padding(Layout.padding)
        }
        .buttonStyle(.plain)
        .glassEffect(isSelected ? .regular.tint(.white.opacity(Layout.selectedTint)) : .regular,
                     in: .rect(cornerRadius: Layout.cornerRadius))
        .accessibilityLabel("\(person.name), \(person.place.city)")
        .accessibilityValue("\(timeText), \(StatusDot.sentence(for: status))")
    }

    private var avatar: String {
        switch person.avatar {
        case .emoji(let emoji): emoji
        }
    }

    private var status: CallStatus {
        CallStatus.status(for: person, at: date)
    }

    private var timeText: String {
        guard let timeZone = person.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return date.formatted(style)
    }
}

extension PersonChip {
    private enum Layout {
        static let width: Double = 104
        static let padding: Double = 12
        static let spacing: Double = 6
        static let avatarGap: Double = 6
        static let dotGap: Double = 4
        static let cornerRadius: Double = 18
        static let selectedTint = 0.18
    }
}
