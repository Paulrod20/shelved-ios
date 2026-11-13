/// A personal rating from 1 to 5 stars. Out-of-range values cannot be constructed.
nonisolated struct Rating: Hashable, Sendable {
    static let range = 1...5

    let value: Int

    init?(_ value: Int) {
        guard Self.range.contains(value) else { return nil }
        self.value = value
    }
}
