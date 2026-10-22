import SkyCore
import SwiftUI

/// One person in the row: who, where, what time it is there, and whether to call.
struct PersonChip: View {
    let person: Person
    let date: Date
    let isSelected: Bool
    let isHome: Bool
    let action: () -> Void

    @Environment(\.locale) private var locale

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Layout.spacing) {
                header
                HStack(alignment: .firstTextBaseline, spacing: Layout.timeGap) {
                    Image(systemName: isDaylight ? "sun.max.fill" : "moon.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(timeText)
                        .font(.title2.weight(.regular))
                        .monospacedDigit()
                    Spacer(minLength: Layout.statusGap)
                    Text(StatusDot.label(for: status))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(StatusDot.colour(for: status))
                }
                .lineLimit(1)
                .minimumScaleFactor(Layout.minimumScale)
            }
            .foregroundStyle(.white)
            .frame(width: Layout.width, alignment: .leading)
            .padding(Layout.padding)
        }
        .buttonStyle(.plain)
        .panel(cornerRadius: Layout.cornerRadius, isHighlighted: isSelected)
        .accessibilityLabel("\(person.name), \(person.place.city)\(isHome ? ", home" : "")")
        .accessibilityValue("\(timeText), \(StatusDot.sentence(for: status))")
    }

    private var header: some View {
        HStack(spacing: Layout.avatarGap) {
            Text(avatar)
                .font(.system(size: Layout.avatarSize))
                .frame(width: Layout.avatarWell, height: Layout.avatarWell)
                .background(.white.opacity(Layout.avatarFill), in: .circle)
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(StatusDot.colour(for: status))
                        .frame(width: Layout.dot, height: Layout.dot)
                }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: Layout.homeGap) {
                    Text(person.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    if isHome {
                        Image(systemName: "house.fill")
                            .font(.system(size: Layout.homeIcon))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(person.place.city)
                    .font(.caption)
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
    enum Layout {
        static let width: Double = 186
        static let height: Double = 104
        static let padding: Double = 14
        static let spacing: Double = 10
        static let avatarGap: Double = 10
        static let avatarSize: Double = 18
        static let avatarWell: Double = 36
        static let avatarFill = 0.10
        static let dot: Double = 10
        static let timeGap: Double = 7
        static let statusGap: Double = 6
        static let cornerRadius: Double = 22
        static let minimumScale = 0.7
        static let homeGap: Double = 4
        static let homeIcon: Double = 9
    }
}
