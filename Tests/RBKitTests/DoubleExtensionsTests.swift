import Dependencies
import Testing

@testable import RBKit

@Suite
struct `Double Extensions Tests` {
    @Test
    func `Radians converts degrees to radians`() {
        let radians = Double(360).radians

        #expect(radians == 2 * .pi)
    }
}
