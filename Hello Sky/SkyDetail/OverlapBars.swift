import SkyUI
import SwiftUI

/// Two days side by side, with the hours they share picked out.
struct OverlapBars: View {
    let homeName: String
    let personName: String
    let homeSlots: [Bool]
    let personSlots: [Bool]

    @Environment(\.theme) private var theme

    var body: some View {
        HStack(alignment: .center, spacing: Layout.labelGap) {
            VStack(alignment: .leading, spacing: Layout.rowGap) {
                Text(homeName).lineLimit(1)
                Text(personName).lineLimit(1)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(width: Layout.labelWidth, alignment: .leading)

            ZStack(alignment: .leading) {
                VStack(spacing: Layout.rowGap) {
                    bar(for: homeSlots)
                    bar(for: personSlots)
                }
                overlapHighlight
            }
        }
    }

    private func bar(for slots: [Bool]) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width / Double(max(slots.count, 1))
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(Layout.trackOpacity))
                ForEach(Self.runs(in: slots), id: \.lowerBound) { run in
                    Capsule()
                        .fill(.white.opacity(Layout.awakeOpacity))
                        .frame(width: width * Double(run.count))
                        .offset(x: width * Double(run.lowerBound))
                }
            }
        }
        .frame(height: Layout.barHeight)
    }

    /// A box drawn round the shared hours, which is the answer the card is for.
    @ViewBuilder
    private var overlapHighlight: some View {
        let shared = zip(homeSlots, personSlots).map { $0 && $1 }
        if let best = Self.runs(in: shared).max(by: { $0.count < $1.count }), best.count >= 2 {
            GeometryReader { proxy in
                let width = proxy.size.width / Double(max(shared.count, 1))
                RoundedRectangle(cornerRadius: Layout.highlightCorner)
                    .strokeBorder(theme.accent.color.opacity(Layout.highlightOpacity),
                                  lineWidth: Layout.highlightWidth)
                    .frame(width: width * Double(best.count))
                    .offset(x: width * Double(best.lowerBound))
                    .shadow(color: theme.accent.color.opacity(Layout.highlightGlow),
                            radius: Layout.highlightGlowRadius)
            }
        }
    }

    /// The stretches of `true` in a run of slots.
    static func runs(in slots: [Bool]) -> [Range<Int>] {
        var found: [Range<Int>] = []
        var start: Int?

        for index in slots.indices {
            if slots[index], start == nil { start = index }
            if !slots[index], let begin = start {
                found.append(begin..<index)
                start = nil
            }
        }
        if let begin = start { found.append(begin..<slots.count) }
        return found
    }
}

extension OverlapBars {
    private enum Layout {
        static let labelWidth: Double = 56
        static let labelGap: Double = 10
        static let rowGap: Double = 6
        static let barHeight: Double = 16
        static let trackOpacity = 0.08
        static let awakeOpacity = 0.55
        static let highlightOpacity = 0.9
        static let highlightWidth: Double = 1.5
        static let highlightCorner: Double = 7
        static let highlightGlow = 0.45
        static let highlightGlowRadius: Double = 6
    }
}
