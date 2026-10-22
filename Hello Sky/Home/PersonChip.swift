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
                header
                HStack(alignment: .firstTextBaseline, spacing: Layout.timeGap) {
                    Image(systemName: isDaylight ? "sun.max.fill" : "moon.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeText)
                        .font(.title2.weight(.light))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(Layout.minimumScale)
                }
                Text(StatusDot.label(for: status))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(StatusDot.colour(for: status))
                    .lineLimit(1)
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

    private var header: some View {
        HStack(spacing: Layout.avatarGap) {
            Text(avatar)
                .font(.system(size: Layout.avatarSize))
                .frame(width: Layout.avatarWell, height: Layout.avatarWell)
                .background(.white.opacity(Layout.avatarBackground), in: .circle)
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(StatusDot.colour(for: status))
                        .frame(width: Layout.dot, height: Layout.dot)
                }
            VStack(alignment: .leading, spacing: 0) {
                Text(person.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(person.place.city)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var avatar: String {
        switch person.avatar {
        case .emoji(let emoji): emoji
        }
    }

    private var status: CallStatus {
        CallStatus.status(for: person, at: date)
    }

    /// Drives the sun or moon beside the time, from the real sun position.
    private var isDaylight: Bool {
        Sun.position(at: date, from: person.place.coordinate).isDaylight
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
        static let width: Double = 138
        static let padding: Double = 14
        static let spacing: Double = 10
        static let avatarGap: Double = 8
        static let avatarSize: Double = 17
        static let avatarWell: Double = 32
        static let avatarBackground = 0.12
        static let dot: Double = 9
        static let timeGap: Double = 6
        static let cornerRadius: Double = 22
        static let selectedTint = 0.18
        static let minimumScale = 0.7
    }
}
