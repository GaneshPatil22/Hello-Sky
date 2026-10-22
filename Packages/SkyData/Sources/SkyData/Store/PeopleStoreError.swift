import Foundation

/// What can go wrong when changing the people list.
public enum PeopleStoreError: Error, Equatable {
    /// v1 holds at most ten people.
    case listIsFull(limit: Int)
    /// That city is already on the list.
    case alreadyAdded(name: String)
    /// The awake window does not describe a real day.
    case invalidAwakeHours
}
