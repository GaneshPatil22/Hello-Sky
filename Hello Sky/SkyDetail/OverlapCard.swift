import SkyCore
import SwiftUI

/// When you and someone else are both awake over the next day.
///
/// Two bars rather than a sentence: the shape of a day shows at a glance where
/// the shared hours are, and a sentence has to be read.
struct OverlapCard: View {
    let home: Person
    let person: Person
    let date: Date
    let accent: Color

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            HStack {
                Text("Best time to call")
                    .font(.headline)
                Spacer()
                Text("next 24 hours")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            OverlapBars(
                homeName: home.name,
                personName: person.name,
                homeSlots: homeSlots,
                personSlots: personSlots,
                accent: accent
            )

            axis

            VStack(alignment: .leading, spacing: Layout.summarySpacing) {
                Text(headline)
                    .font(.subheadline.weight(.semibold))
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(Layout.padding)
        .panel()
    }

    private var axis: some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.axisHours.enumerated()), id: \.offset) { _, hour in
                Text(label(hoursFromNow: hour))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: hour == 0 ? .leading : .center)
            }
        }
    }

    private var homeSlots: [Bool] { Overlap.awakeSlots(for: home, from: date) }
    private var personSlots: [Bool] { Overlap.awakeSlots(for: person, from: date) }

    private var window: OverlapWindow? {
        Overlap.bestWindow(between: home, and: person, from: date)
    }

    private var headline: String {
        guard let window else { return "No shared waking hours in the next 24 hours" }
        let start = window.start.timeIntervalSince(date) < Layout.rightNowWithin
            ? "Right now"
            : formatted(window.start, for: home)
        return "\(start) until \(formatted(window.end, for: home)) your time"
    }

    private var detail: String? {
        guard let window else { return "Try the slider to find the next window." }
        let hours = (window.hours * 10).rounded() / 10
        let trimmed = hours == hours.rounded() ? String(Int(hours)) : String(hours)
        return "\(formatted(window.start, for: person)) to \(formatted(window.end, for: person)) "
            + "for \(person.name), \(trimmed) h of overlap"
    }

    private func formatted(_ moment: Date, for who: Person) -> String {
        guard let timeZone = who.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return moment.formatted(style)
    }

    /// "now", then the hour at each quarter of the day, read on your clock.
    private func label(hoursFromNow hours: Int) -> String {
        guard hours > 0 else { return "now" }
        guard let timeZone = home.place.timeZone else { return "—" }
        var style = Date.FormatStyle.dateTime.hour(.defaultDigits(amPM: .narrow))
        style.timeZone = timeZone
        style.locale = locale
        return date.addingTimeInterval(Double(hours) * 3_600).formatted(style)
    }

    static let axisHours = [0, 6, 12, 18, 24]
}

extension OverlapCard {
    private enum Layout {
        static let spacing: Double = 12
        static let summarySpacing: Double = 3
        static let padding: Double = 18
        /// A window starting within this counts as starting now.
        static let rightNowWithin: TimeInterval = 20 * 60
    }
}
