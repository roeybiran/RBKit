import Testing
@testable import RBKit

@Suite
struct `Collection Extensions Tests` {
    @Test
    func `Safe subscript returns nil for out of range indices`() {
        let values = [1, 2, 3]
        #expect(values[safe: 3] == nil)
        #expect(values[safe: 2] == 3)
    }
}
