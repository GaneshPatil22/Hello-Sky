import Foundation

/// The state of the move between the globe and someone's sky.
///
/// A small machine rather than a pile of booleans, so the rule that matters —
/// that a second tap cannot start while a transition is running — is one place
/// and can be tested. The prototype got this wrong and could leave the globe
/// zooming towards one city while the sky showed another.
public struct SkyTransition: Hashable, Sendable {
    public enum Phase: Hashable, Sendable {
        /// The globe, with nobody's sky showing.
        case globe
        /// Turning towards a city and revealing their sky.
        case opening(personID: String)
        /// Their sky, filling the screen.
        case sky(personID: String)
        /// Folding the sky away, back to the globe.
        case closing(personID: String)
    }

    public private(set) var phase: Phase = .globe

    public init() {}

    /// Whose sky is on screen or on its way there.
    public var personID: String? {
        switch phase {
        case .globe: nil
        case .opening(let id), .sky(let id), .closing(let id): id
        }
    }

    /// True while the screen is mid-move and must not be interrupted.
    public var isMoving: Bool {
        switch phase {
        case .opening, .closing: true
        case .globe, .sky: false
        }
    }

    /// Whether any part of a sky should be drawn.
    public var isShowingSky: Bool {
        phase != .globe
    }

    /// Starts opening someone's sky. Returns false if the screen is busy.
    @discardableResult
    public mutating func open(personID: String) -> Bool {
        guard phase == .globe else { return false }
        phase = .opening(personID: personID)
        return true
    }

    /// The opening animation has landed.
    public mutating func finishOpening() {
        guard case .opening(let id) = phase else { return }
        phase = .sky(personID: id)
    }

    /// Starts going back. Returns false if the screen is busy.
    @discardableResult
    public mutating func close() -> Bool {
        guard case .sky(let id) = phase else { return false }
        phase = .closing(personID: id)
        return true
    }

    /// The closing animation has finished.
    public mutating func finishClosing() {
        guard case .closing = phase else { return }
        phase = .globe
    }
}

extension SkyTransition {
    /// How long each part of the move takes.
    ///
    /// The whole thing is about a second and a half, which the plan picked as
    /// long enough to read as travel and short enough not to be in the way.
    public enum Timing {
        /// Turning the globe to put the city in the middle.
        public static let focus: TimeInterval = 0.85
        /// The circle opening over the globe.
        public static let reveal: TimeInterval = 0.55
        /// How far into the turn the reveal starts, so they overlap.
        public static let revealDelay: TimeInterval = 0.55
        /// Folding back, which is quicker than opening.
        public static let close: TimeInterval = 0.45

        public static var total: TimeInterval { revealDelay + reveal }
    }
}
