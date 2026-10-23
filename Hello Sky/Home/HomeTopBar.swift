import SwiftUI

/// The title row: what the app is, and the three things you can reach from it.
struct HomeTopBar: View {
    let canAddPerson: Bool
    let onAddPerson: () -> Void
    let onChooseLook: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Text(Copy.planet)
                .font(.title2)
                .accessibilityHidden(true)
            Text(Copy.title)
                .font(.title2.weight(.bold))

            Spacer()

            button("Add Person", systemImage: "plus", action: onAddPerson)
                .disabled(!canAddPerson)
                .accessibilityHint(canAddPerson ? "" : "The list is full. Remove someone first.")
            button("Look", systemImage: "paintpalette", action: onChooseLook)
            button("Settings", systemImage: "gearshape", action: onOpenSettings)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, Layout.padding)
    }

    private func button(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .font(.footnote.weight(.semibold))
            .frame(width: Layout.button, height: Layout.button)
            .panel(cornerRadius: Layout.button / 2)
    }
}

extension HomeTopBar {
    private enum Copy {
        static let planet = "🪐"
        /// The product's name. The prototype this is modelled on was called
        /// Same Sky; the app itself is Hello Sky.
        static let title = "Hello Sky"
    }

    private enum Layout {
        static let spacing: Double = 10
        static let padding: Double = 20
        static let button: Double = 34
    }
}
