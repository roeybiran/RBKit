import Dependencies
import Testing

@testable import RBKit

@Suite
struct `Double Tests` {
    @Test
    func `radians, should convert degrees to radians`() async throws {
        let radians = Double(360).radians

        #expect(radians == 2 * .pi)
    }
}
