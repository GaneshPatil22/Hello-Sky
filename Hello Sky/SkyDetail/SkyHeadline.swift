import SkyCore
import SwiftUI

/// The clock, where it is, and whether to call — the part that sits on the sky.
struct SkyHeadline: View {
    let person: Person
    let home: Person?
    let date: Date
    let weather: SkyWeather

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(spacing: Layout.spacing) {
            clock
            Text(whereAndWhen)
                .font(.headline.weight(.regular))
                .foregroundStyle(.white.opacity(Layout.captionOpacity))
                .multilineTextAlignment(.center)
            statusPill
            WeatherChips(weather: weather)
        }
        .foregroundStyle(.white)
        .shadow(radius: Layout.shadow)
    }

    /// The time, with the period set small beside it rather than shouted.
    private var clock: some View {
        HStack(alignment: .lastTextBaseline, spacing: Layout.periodGap) {
            Text(parts.time)
                .font(.system(size: Layout.clock, weight: .light, design: .rounded))
                .monospacedDigit()
            if let period = parts.period {
                Text(period)
                    .font(.system(size: Layout.period, weight: .regular, design: .rounded))
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(Layout.minimumScale)
        .accessibilityElement()
        .accessibilityLabel(timeText)
    }

    private var statusPill: some View {
        HStack(spacing: Layout.dotGap) {
            Circle()
                .fill(StatusDot.colour(for: status))
                .frame(width: Layout.dot, height: Layout.dot)
            Text(StatusDot.sentence(for: status))
                .font(.headline)
                .foregroundStyle(StatusDot.colour(for: status))
        }
        .padding(.horizontal, Layout.pillPaddingX)
        .padding(.vertical, Layout.pillPaddingY)
        .panel(cornerRadius: Layout.pillCorner)
    }

    private var status: CallStatus {
        CallStatus.status(for: person, at: date)
    }

    /// "Today in Nairobi, 2 hours ahead of you".
    private var whereAndWhen: String {
        guard let zone = person.place.timeZone else { return person.place.city }
        let day: String
        if let homeZone = home?.place.timeZone {
            day = switch LocalTime.relativeDay(at: date, in: zone, comparedTo: homeZone) {
            case .yesterday: "Yesterday"
            case .sameDay: "Today"
            case .tomorrow: "Tomorrow"
            }
        } else {
            day = "Today"
        }

        guard let homeZone = home?.place.timeZone, home?.id != person.id else {
            return "\(day) in \(person.place.city)"
        }
        return "\(day) in \(person.place.city), \(Self.offsetPhrase(from: homeZone, to: zone, at: date))"
    }

    /// "2 hours ahead of you", or "the same time as you".
    static func offsetPhrase(from home: TimeZone, to other: TimeZone, at date: Date) -> String {
        let hours = LocalTime.offset(at: date, from: home, to: other)
        guard abs(hours) >= 0.01 else { return "the same time as you" }

        let size = abs(hours)
        let whole = size.rounded() == size ? String(Int(size)) : String(format: "%.1f", size)
        let unit = size == 1 ? "hour" : "hours"
        return "\(whole) \(unit) \(hours > 0 ? "ahead of" : "behind") you"
    }

    private var timeText: String {
        guard let timeZone = person.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return date.formatted(style)
    }

    /// Splits "11:14 AM" so the period can be set smaller.
    ///
    /// Split on the last space of any kind: some locales put a narrow no-break
    /// space before the period, which a plain " AM" check misses, leaving the
    /// whole string in the very large font.
    static func split(_ text: String) -> (time: String, period: String?) {
        guard let gap = text.lastIndex(where: \.isWhitespace) else { return (text, nil) }
        let period = String(text[text.index(after: gap)...])
        guard period.count <= Layout.longestPeriod, !period.contains(where: \.isNumber) else {
            return (text, nil)
        }
        return (String(text[..<gap]), period)
    }

    private var parts: (time: String, period: String?) {
        Self.split(timeText)
    }
}

extension SkyHeadline {
    private enum Layout {
        static let spacing: Double = 11
        static let clock: Double = 68
        static let period: Double = 26
        static let periodGap: Double = 6
        static let minimumScale = 0.5
        static let captionOpacity = 0.85
        static let shadow: Double = 10
        static let dot: Double = 10
        static let dotGap: Double = 8
        static let pillPaddingX: Double = 16
        static let pillPaddingY: Double = 9
        static let pillCorner: Double = 20
        /// "AM", "PM", and the like. Anything longer is part of the time.
        static let longestPeriod = 3
    }
}
