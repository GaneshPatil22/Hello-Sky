import SkyCore
import SwiftUI

/// The card that says which moment the whole screen is showing, and lets you
/// move it.
struct TimeSlider: View {
    @Bindable var time: TimeTravel
    /// Whose clock the caption reads from, normally home.
    let reference: Person?

    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Button(action: returnToNow) {
                Image(systemName: time.isNow ? "clock" : "arrow.uturn.backward")
                    .font(.body.weight(.semibold))
                    .frame(width: Layout.button, height: Layout.button)
            }
            .buttonStyle(.plain)
            .background(.white.opacity(Layout.buttonFill), in: .circle)
            .disabled(time.isNow)
            .accessibilityLabel(time.isNow ? "Showing now" : "Back to now")

            VStack(alignment: .leading, spacing: Layout.rowSpacing) {
                HStack(alignment: .firstTextBaseline, spacing: Layout.labelSpacing) {
                    Text(offsetLabel)
                        .font(.headline)
                    if let caption {
                        Text(caption)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(Layout.minimumScale)
                    }
                }
                Slider(value: $time.scrubbedOffset,
                       in: TimeTravel.Constants.range,
                       step: TimeTravel.Constants.step) {
                    Text("Time")
                }
                .tint(.white.opacity(Layout.sliderTint))
                .accessibilityValue(caption ?? offsetLabel)
            }
        }
        .foregroundStyle(.white)
        .padding(Layout.padding)
        .panel(cornerRadius: Layout.corner)
    }

    /// Reduce Motion gets there at once; everyone else watches it travel.
    private func returnToNow() {
        if reduceMotion {
            time.jumpToNow()
        } else {
            time.returnToNow()
        }
    }

    private var offsetLabel: String {
        guard !time.isNow else { return "Now" }
        let hours = Int(time.offsetHours.rounded())
        guard hours != 0 else { return "Now" }
        return hours > 0 ? "+\(hours) h" : "\(hours) h"
    }

    /// "Thu 7:35 PM in London", so the moment is never ambiguous.
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
        static let spacing: Double = 14
        static let rowSpacing: Double = 2
        static let labelSpacing: Double = 10
        static let padding: Double = 16
        static let corner: Double = 26
        static let button: Double = 44
        static let buttonFill = 0.12
        static let sliderTint = 0.9
        static let minimumScale = 0.8
    }
}
