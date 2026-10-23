import Foundation

/// A sunrise or a sunset, and when it happens.
public struct SolarEvent: Hashable, Sendable {
    public enum Kind: String, Hashable, Sendable {
        case sunrise
        case sunset
    }

    public let kind: Kind
    public let date: Date

    public init(kind: Kind, date: Date) {
        self.kind = kind
        self.date = date
    }
}
