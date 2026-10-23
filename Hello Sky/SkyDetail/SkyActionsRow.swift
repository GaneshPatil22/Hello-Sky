import SkyCore
import SwiftUI

/// The two things you can do from someone's sky.
struct SkyActionsRow: View {
    let card: SkyCardTransfer
    let shareTitle: String
    let reminderTitle: String
    let isReminderSet: Bool
    let onRemind: () -> Void

    var body: some View {
        HStack(spacing: Layout.spacing) {
            ShareLink(item: card, preview: SharePreview(shareTitle)) {
                Label("Share sky card", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.padding)
            }
            .foregroundStyle(.black)
            .background(.white.opacity(Layout.filledOpacity), in: .rect(cornerRadius: Layout.corner))

            Button(action: onRemind) {
                Label(reminderTitle, systemImage: isReminderSet ? "bell.fill" : "bell")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Layout.padding)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .panel(cornerRadius: Layout.corner)
        }
        .labelStyle(.titleAndIcon)
        .multilineTextAlignment(.center)
    }
}

extension SkyActionsRow {
    private enum Layout {
        static let spacing: Double = 12
        static let padding: Double = 14
        static let corner: Double = 18
        static let filledOpacity = 0.88
    }
}
