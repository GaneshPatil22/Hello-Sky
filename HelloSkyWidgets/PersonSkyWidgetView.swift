import SwiftUI

/// A person's name, their local time, and their city.
struct PersonSkyWidgetView: View {
    let entry: PersonSkyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Layout.spacing) {
            Text(entry.person.name)
                .font(.caption)
            Spacer(minLength: 0)
            Text(entry.date, format: .dateTime.hour().minute())
                .font(.title)
            Text(entry.person.place.city)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension PersonSkyWidgetView {
    private enum Layout {
        static let spacing: Double = 2
    }
}
