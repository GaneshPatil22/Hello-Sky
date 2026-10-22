import Foundation

extension String {
    /// A hash that is the same in every launch.
    ///
    /// Swift's `hashValue` is seeded per process, so anything derived from it
    /// changes between runs. The sky seeds its stars and clouds from a place's
    /// id, and snapshot tests compare rendered images, so that will not do.
    public var stableHash: UInt64 {
        // FNV-1a, chosen for being short and well understood rather than strong.
        var hash = Constants.offsetBasis
        for byte in utf8 {
            hash ^= UInt64(byte)
            hash &*= Constants.prime
        }
        return hash
    }

    private enum Constants {
        static let offsetBasis: UInt64 = 14_695_981_039_346_656_037
        static let prime: UInt64 = 1_099_511_628_211
    }
}
