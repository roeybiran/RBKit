import Testing
@testable import RBKit

@Suite
struct `Collection Tests` {
    @Test
    func `subscript safe:, with out of range index, should return nil`() async throws {
        let values = [1, 2, 3]
        #expect(values[safe: 3] == nil)
    }

    @Test
    func `subscript safe:, with valid index, should return element`() async throws {
        let values = [1, 2, 3]
        #expect(values[safe: 2] == 3)
    }
}
