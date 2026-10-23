import Foundation
import Observation
import SkyCore
import SkyData

/// What the add-person sheet is holding while it is open.
///
/// Kept out of the view so the rules — when Add is allowed, what a failure says
/// — can be read and tested without rendering anything.
@MainActor
@Observable
final class AddPersonModel {
    var name = ""
    var avatarEmoji = avatarChoices[0]
    var query = ""
    var awakeStart = AwakeHours.default.start
    var awakeEnd = AwakeHours.default.end

    private(set) var results: [City] = []
    private(set) var selectedCity: City?
    private(set) var failure: String?
    /// True while a search is in flight, so the field can say so.
    private(set) var isSearching = false
    /// True once a search has run and found nothing.
    private(set) var hasSearched = false

    private let search: any CitySearching

    init(search: any CitySearching = MapKitCitySearch()) {
        self.search = search
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var awakeHours: AwakeHours {
        AwakeHours(start: awakeStart, end: awakeEnd)
    }

    var canAdd: Bool {
        selectedCity != nil && !trimmedName.isEmpty && awakeHours.isValid
    }

    /// Why Add is not available yet, for a line under the button.
    var blocker: String? {
        if selectedCity == nil { return "Choose a city first." }
        if trimmedName.isEmpty { return "Give them a name." }
        if !awakeHours.isValid { return "Waking hours have to start before they end." }
        return nil
    }

    var startLabel: String { Self.hourLabel(awakeStart) }
    var endLabel: String { Self.hourLabel(awakeEnd) }

    /// "Awake for 15 hours", so the two pickers add up to something readable.
    var awakeSummary: String {
        guard awakeHours.isValid else { return "That is not a day." }
        let hours = awakeHours.duration
        let whole = hours == hours.rounded() ? String(Int(hours)) : String(format: "%.1f", hours)
        return "Awake for \(whole) hours"
    }

    func search() async {
        let wanted = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !wanted.isEmpty else {
            results = []
            hasSearched = false
            return
        }

        isSearching = true
        defer { isSearching = false }
        let found = (try? await search.cities(matching: wanted)) ?? []
        // A slow search finishing after the text has moved on must not replace
        // results for what is now on screen.
        guard wanted == query.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        results = found
        hasSearched = true
    }

    func select(_ city: City) {
        selectedCity = city
        // The name field is left alone: nobody is called Tokyo, and a
        // prefilled name has to be cleared before the real one is typed.
        query = city.qualifiedName
        results = []
        hasSearched = false
        failure = nil
    }

    /// Goes back to searching, keeping what was typed so it can be edited.
    func changeCity() {
        selectedCity = nil
        results = []
        hasSearched = false
    }

    /// Returns whether the person was added; sets `failure` when not.
    func add(to store: PeopleStore) -> Bool {
        guard let city = selectedCity else { return false }
        do {
            try store.add(
                name: trimmedName,
                avatar: .emoji(avatarEmoji),
                city: city,
                awakeHours: awakeHours
            )
            failure = nil
            return true
        } catch let error as PeopleStoreError {
            failure = Self.message(for: error)
            return false
        } catch {
            failure = error.localizedDescription
            return false
        }
    }

    static func message(for error: PeopleStoreError) -> String {
        switch error {
        case .listIsFull(let limit): "You can follow up to \(limit) people."
        case .alreadyAdded(let name): "\(name) is already on your list."
        case .invalidAwakeHours: "Waking hours have to start before they end."
        }
    }

    static func hourLabel(_ hour: Double) -> String {
        var components = DateComponents()
        components.hour = Int(hour) % 24
        components.minute = Int((hour - Double(Int(hour))) * 60)
        let date = Calendar.current.date(from: components) ?? .now
        // Midnight at the end of a day reads better as the end than the start.
        let text = date.formatted(.dateTime.hour().minute())
        return hour == 24 ? "Midnight" : text
    }

    /// The hours someone can pick from, on the hour and the half hour.
    static let hourChoices: [Double] = stride(from: 0.0, through: 24.0, by: 0.5).map { $0 }

    static let avatarChoices = [
        "🙂", "🦊", "🐼", "🌻", "🎸", "🚀", "🐢", "🍜",
        "🧢", "🎧", "👩", "🧔", "🪁", "🌴", "🦒", "🐙",
    ]
}
