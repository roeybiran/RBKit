import Testing

@testable import RBKit

@Suite
struct `clamp Tests` {
    @Test
    func `clamp, with ideal exceeding max, should return max`() async throws {
        #expect(clamp(min: 2, ideal: 999, max: 10) == 10)
    }

    @Test
    func `clamp, with ideal within range, should return ideal`() async throws {
        #expect(clamp(min: 2, ideal: 5, max: 10) == 5)
    }
}
