import SkyCore
import SwiftUI

/// The card that says which moment the whole screen is showing, and lets you
/// move it.
struct TimeSlider: View {
    /// How much room the slider is given.
    enum Style {
        /// A card with the moment spelled out, for the globe.
        case card
        /// A single row, for a screen that already says where and when it is.
        case compact
    }

    @Bindable var time: TimeTravel
    /// Whose clock the caption reads from, normally home.
    let reference: Person?
    var style: Style = .card
    /// Overrides the look's own tint, so the sky screen's slider matches the
    /// sky it is sitting on.
    var accent: Color?

    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        switch style {
        case .card: card
        case .compact: compact
        }
    }

    /// Offset on the left, slider filling the rest.
    private var compact: some View {
        HStack(spacing: Layout.spacing) {
            Text(offsetLabel)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .frame(width: Layout.compactLabel, alignment: .leading)
            Slider(value: $time.scrubbedOffset,
                   in: TimeTravel.Constants.range,
                   step: TimeTravel.Constants.step) {
                Text("Time")
            }
            .tint(accent ?? .white.opacity(Layout.sliderTint))
            .accessibilityValue(caption ?? offsetLabel)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Layout.padding)
        .padding(.vertical, Layout.compactPadding)
        .panel(cornerRadius: Layout.corner)
    }

    private var card: some View {
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
                .tint(accent ?? .white.opacity(Layout.sliderTint))
                .accessibilityValue(caption ?? offsetLabel)
            }
        }
        .foregroundStyle(.white)
        .padding(Layout.padding)
        .panel(cornerRadius: Layout.corner)
    }

    /// "+19h 15m", so a glance says how far from now this is.
    private var offsetLabel: String {
        guard !time.isNow else { return "Now" }
        let minutes = Int((abs(time.offsetHours) * 60).rounded())
        let sign = time.offsetHours > 0 ? "+" : "\u{2212}"
        let hours = minutes / 60
        let remainder = minutes % 60

        if hours == 0 { return "\(sign)\(remainder)m" }
        return remainder == 0 ? "\(sign)\(hours)h" : "\(sign)\(hours)h \(remainder)m"
    }

    /// Reduce Motion gets there at once; everyone else watches it travel.
    private func returnToNow() {
        if reduceMotion {
            time.jumpToNow()
        } else {
            time.returnToNow()
        }
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
        static let compactLabel: Double = 74
        static let compactPadding: Double = 10
    }
}
