import QuartzCore
import Testing

@testable import RBKit

@Suite
struct `CACornerMask Tests` {
    @Test
    func `topLeft, should equal layerMinXMaxYCorner`() async throws {
        #expect(CACornerMask.topLeft == .layerMinXMaxYCorner)
    }

    @Test
    func `topRight, should equal layerMaxXMaxYCorner`() async throws {
        #expect(CACornerMask.topRight == .layerMaxXMaxYCorner)
    }

    @Test
    func `bottomRight, should equal layerMaxXMinYCorner`() async throws {
        #expect(CACornerMask.bottomRight == .layerMaxXMinYCorner)
    }

    @Test
    func `bottomLeft, should equal layerMinXMinYCorner`() async throws {
        #expect(CACornerMask.bottomLeft == .layerMinXMinYCorner)
    }

    @Test
    func `all, should equal all corners`() async throws {
        #expect(CACornerMask.all == [.topLeft, .topRight, .bottomLeft, .bottomRight])
    }
}
