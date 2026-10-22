import SwiftUI

/// The slider across the day, with a tap to come back to now.
struct TimeSlider: View {
    @Bindable var time: TimeTravel

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Slider(
                value: $time.offsetHours,
                in: TimeTravel.Constants.range,
                step: TimeTravel.Constants.step
            ) {
                Text("Time")
            }
            .accessibilityValue(label)

            Button("Now") { time.reset() }
                .font(.caption.weight(.medium))
                .disabled(time.isNow)
                .opacity(time.isNow ? Layout.restingOpacity : 1)
        }
        .padding(.horizontal, Layout.padding)
        .padding(.vertical, Layout.verticalPadding)
        .glassEffect(in: .rect(cornerRadius: Layout.corner))
    }

    private var label: String {
        if time.isNow { return "Now" }
        let hours = Int(time.offsetHours.rounded())
        return hours > 0 ? "\(hours) hours from now" : "\(-hours) hours ago"
    }
}

extension TimeSlider {
    private enum Layout {
        static let spacing: Double = 12
        static let padding: Double = 16
        static let verticalPadding: Double = 8
        static let corner: Double = 22
        static let restingOpacity = 0.4
    }
}
