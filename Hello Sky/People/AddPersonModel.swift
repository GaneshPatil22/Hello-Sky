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

    private let search: any CitySearching

    init(search: any CitySearching = MapKitCitySearch()) {
        self.search = search
    }

    var canAdd: Bool {
        selectedCity != nil
            && !name.trimmingCharacters(in: .whitespaces).isEmpty
            && AwakeHours(start: awakeStart, end: awakeEnd).isValid
    }

    var startLabel: String { Self.hourLabel(awakeStart) }
    var endLabel: String { Self.hourLabel(awakeEnd) }

    func search() async {
        guard selectedCity == nil else { return }
        results = (try? await search.cities(matching: query)) ?? []
    }

    func select(_ city: City) {
        selectedCity = city
        if name.isEmpty { name = city.name }
        query = ""
        results = []
    }

    func clearCity() {
        selectedCity = nil
    }

    /// Returns whether the person was added; sets `failure` when not.
    func add(to store: PeopleStore) -> Bool {
        guard let city = selectedCity else { return false }
        do {
            try store.add(
                name: name.trimmingCharacters(in: .whitespaces),
                avatar: .emoji(avatarEmoji),
                city: city,
                awakeHours: AwakeHours(start: awakeStart, end: awakeEnd)
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

    private static func hourLabel(_ hour: Double) -> String {
        var components = DateComponents()
        components.hour = Int(hour)
        components.minute = Int((hour - Double(Int(hour))) * 60)
        let date = Calendar.current.date(from: components) ?? .now
        return date.formatted(.dateTime.hour().minute())
    }

    static let avatarChoices = ["🙂", "🦊", "🐼", "🌻", "🎸", "🚀", "🐢", "🍜", "🧢", "🎧", "👩", "🧔"]
}
