import Foundation

/// Fetching bytes from a URL.
///
/// A seam so a provider can be driven from a saved response in tests without
/// a network, and so contract tests run against the real decoding path.
public protocol HTTPLoading: Sendable {
    func data(from url: URL) async throws -> Data
}

/// The real network.
public struct URLSessionLoader: HTTPLoading {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(from url: URL) async throws -> Data {
        try await session.data(from: url).0
    }
}
