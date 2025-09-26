import Testing

@testable import RBKit

@Suite
struct `Clamp Tests` {
    @Test
    func `Clamp bounds values`() {
        #expect(clamp(min: 2, ideal: 999, max: 10) == 10)
        #expect(clamp(min: 2, ideal: 5, max: 10) == 5)
    }
}
