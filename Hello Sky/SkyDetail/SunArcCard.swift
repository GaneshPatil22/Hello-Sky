import SkyCore
import SkyUI
import SwiftUI

/// Where the sun has got to, and how long until it next crosses the horizon.
struct SunArcCard: View {
    let person: Person
    let date: Date

    @Environment(\.locale) private var locale
    @Environment(\.theme) private var theme

    var body: some View {
        HStack(spacing: Layout.spacing) {
            arc
            VStack(alignment: .leading, spacing: Layout.textSpacing) {
                Text(headline)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(Layout.minimumScale)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(Layout.padding)
        .panel()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(headline). \(detail)")
    }

    private var arc: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                let rect = CGRect(
                    x: 0, y: 0,
                    width: proxy.size.width,
                    height: proxy.size.height - Layout.groundInset
                )
                // The path ahead in dashes, the path already travelled solid,
                // so the day reads as something partly used up.
                SunArcShape()
                    .path(in: rect)
                    .stroke(.white.opacity(Layout.futureOpacity),
                            style: StrokeStyle(lineWidth: Layout.line, dash: Layout.dash))
                SunArcShape(portion: progress)
                    .path(in: rect)
                    .stroke(theme.accent.color.opacity(Layout.pastOpacity), lineWidth: Layout.line)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: rect.maxY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                }
                .stroke(.white.opacity(Layout.groundOpacity), lineWidth: Layout.groundLine)

                let sun = SunArcShape.point(at: progress, in: rect)
                Circle()
                    .fill(.white)
                    .frame(width: Layout.sun, height: Layout.sun)
                    .shadow(color: theme.accent.color.opacity(Layout.glowOpacity), radius: Layout.glow)
                    .position(sun)
            }
        }
        .frame(width: Layout.arcWidth, height: Layout.arcHeight)
    }

    private var solarDay: SolarDay {
        Sun.solarDay(around: date, at: person.place.coordinate)
    }

    /// How far through the daylight hours it is.
    ///
    /// At night the sun waits at the start of the arc when a sunrise is coming,
    /// so the drawing reads as the day ahead rather than as one just finished.
    private var progress: Double {
        let day = solarDay
        guard day.isDaylight else { return day.next?.kind == .sunrise ? 0 : 1 }
        guard let sunrise = day.previous?.date, let sunset = day.next?.date, sunset > sunrise else {
            return 0.5
        }
        return (date.timeIntervalSince(sunrise) / sunset.timeIntervalSince(sunrise))
            .clamped(to: 0...1)
    }

    private var headline: String {
        guard let next = solarDay.next else {
            return solarDay.polarCondition == .midnightSun ? "The sun stays up" : "The sun stays down"
        }
        let name = next.kind == .sunrise ? "Sunrise" : "Sunset"
        return "\(name) in \(Self.until(next.date, from: date))"
    }

    private var detail: String {
        guard let next = solarDay.next, let timeZone = person.place.timeZone else {
            return person.place.city
        }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        let phase = solarDay.isDaylight ? "daytime" : "night"
        return "\(next.date.formatted(style)), \(phase)"
    }

    /// "7 h 7 min", which is how long it is rather than when it happens.
    static func until(_ moment: Date, from now: Date) -> String {
        let minutes = max(Int(moment.timeIntervalSince(now) / 60), 0)
        let hours = minutes / 60
        let remainder = minutes % 60
        if hours == 0 { return "\(remainder) min" }
        return remainder == 0 ? "\(hours) h" : "\(hours) h \(remainder) min"
    }
}

extension SunArcCard {
    private enum Layout {
        static let spacing: Double = 18
        static let textSpacing: Double = 3
        static let padding: Double = 18
        static let arcWidth: Double = 108
        static let arcHeight: Double = 62
        static let groundInset: Double = 6
        static let line: Double = 1.6
        static let groundLine: Double = 1
        static let dash: [CGFloat] = [3, 4]
        static let futureOpacity = 0.35
        static let pastOpacity = 0.9
        static let groundOpacity = 0.25
        static let sun: Double = 11
        static let glow: Double = 6
        static let glowOpacity = 0.8
        static let minimumScale = 0.7
    }
}
