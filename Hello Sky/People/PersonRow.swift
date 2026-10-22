import SkyCore
import SwiftUI

/// One person: who they are, what time it is there, and whether to call.
struct PersonRow: View {
    let person: Person
    let date: Date

    @Environment(\.locale) private var locale

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Text(avatarText)
                .font(.title2)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(person.name)
                Text(person.place.city)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                if let timeZone = person.place.timeZone {
                    Text(date, format: clockFormat(in: timeZone))
                        .monospacedDigit()
                } else {
                    Text("Unknown time zone")
                        .foregroundStyle(.secondary)
                }
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// Each row shows a different zone, so the style carries one rather than
    /// reading the environment's.
    private func clockFormat(in timeZone: TimeZone) -> Date.FormatStyle {
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return style
    }

    private var avatarText: String {
        switch person.avatar {
        case .emoji(let emoji): emoji
        }
    }

    /// Spelled out rather than shown only as a colour, so it reads the same
    /// without colour vision and to VoiceOver.
    private var statusText: String {
        switch CallStatus.status(for: person, at: date) {
        case .good: "Good time to call"
        case .maybe: "Maybe"
        case .sleeping: "Asleep"
        }
    }
}

extension PersonRow {
    private enum Layout {
        static let spacing: Double = 12
    }
}
