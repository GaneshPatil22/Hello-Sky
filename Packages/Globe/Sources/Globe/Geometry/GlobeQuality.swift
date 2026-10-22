import Foundation

/// How much the globe is allowed to cost.
///
/// iOS 27 still reaches phones older than the baseline, which cannot be tested
/// here, so the tier drops itself when frames start arriving late rather than
/// trusting a device list.
public enum GlobeQuality: String, Hashable, Sendable, CaseIterable, Comparable {
    case low
    case medium
    case high

    public var textureWidth: Int {
        switch self {
        case .low: 1_024
        case .medium: 2_048
        case .high: 4_096
        }
    }

    public var drawsClouds: Bool { self != .low }
    public var drawsAtmosphere: Bool { self == .high }

    /// Rough bytes for one RGBA texture at this size, mipmaps included.
    public var textureBytes: Int {
        let pixels = textureWidth * (textureWidth / 2)
        return Int(Double(pixels * 4) * Constants.mipmapOverhead)
    }

    public static func < (lhs: GlobeQuality, rhs: GlobeQuality) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }
}

extension GlobeQuality {
    enum Constants {
        /// A full mipmap chain adds about a third again.
        static let mipmapOverhead = 1.34
    }
}
