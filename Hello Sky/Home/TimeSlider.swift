import SkyCore
import SwiftUI

/// The slider across the day, with what moment it is showing spelled out.
///
/// The label is the point: a slider on its own says "some time", where
/// "Thu 7:12 PM in London" says exactly which moment every other screen means.
struct TimeSlider: View {
    @Bindable var time: TimeTravel
    /// Whose clock the label reads from, usually you.
    let reference: Person?

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(spacing: Layout.rowSpacing) {
            HStack(spacing: Layout.spacing) {
                Button(action: time.reset) {
                    Image(systemName: time.isNow ? "clock" : "arrow.uturn.backward")
                        .font(.footnote.weight(.semibold))
                        .frame(width: Layout.buttonSize, height: Layout.buttonSize)
                }
                .buttonStyle(.plain)
                .background(.white.opacity(Layout.buttonBackground), in: .circle)
                .disabled(time.isNow)
                .accessibilityLabel(time.isNow ? "Showing now" : "Back to now")

                VStack(alignment: .leading, spacing: 0) {
                    Text(offsetLabel)
                        .font(.subheadline.weight(.semibold))
                    if let caption {
                        Text(caption)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }

            Slider(value: $time.offsetHours,
                   in: TimeTravel.Constants.range,
                   step: TimeTravel.Constants.step) {
                Text("Time")
            }
            .accessibilityValue(offsetLabel)
        }
        .padding(.horizontal, Layout.padding)
        .padding(.vertical, Layout.verticalPadding)
        .glassEffect(in: .rect(cornerRadius: Layout.corner))
    }

    private var offsetLabel: String {
        guard !time.isNow else { return "Now" }
        let hours = Int(time.offsetHours.rounded())
        if hours == 0 { return "Now" }
        return hours > 0 ? "+\(hours) h" : "\(hours) h"
    }

    /// "Thu 7:12 PM in London", from the reference person's own clock.
    private var caption: String? {
        guard let reference, let timeZone = reference.place.timeZone else { return nil }
        var style = Date.FormatStyle.dateTime.weekday(.abbreviated).hour().minute()
        style.timeZone = timeZone
        style.locale = locale
        return "\(time.date().formatted(style)) in \(reference.place.city)"
    }
}

extension TimeSlider {
    private enum Layout {
        static let spacing: Double = 10
        static let rowSpacing: Double = 6
        static let padding: Double = 16
        static let verticalPadding: Double = 12
        static let corner: Double = 24
        static let buttonSize: Double = 30
        static let buttonBackground = 0.14
    }
}
