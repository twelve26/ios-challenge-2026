import Foundation

/// Zero-based pagination values shared by list services.
public struct Pagination: Equatable, Sendable {
    public let page: Int
    public let limit: Int

    public init(page: Int = 0, limit: Int = 20) {
        self.page = max(0, page)
        self.limit = min(max(1, limit), 1_000)
    }
}
