import Testing

@testable import RBKit

@Suite
struct `Array Extensions Tests` {
    @Test
    func `Safe subscript get and set`() {
        var values = ["a", "b", "c"]

        #expect(values[safe: 3] == nil)
        #expect(values[safe: 0] == "a")

        values[safe: 0] = "z"
        #expect(values[safe: 0] == "z")

        values[safe: 9] = "y"
        #expect(values[safe: 9] == nil)
    }
}
