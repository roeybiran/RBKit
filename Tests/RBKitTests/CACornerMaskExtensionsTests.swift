import QuartzCore
import Testing

@testable import RBKit

@Suite
struct `CACornerMask Extensions Tests` {
    @Test
    func `Convenience masks cover corners`() {
        #expect(CACornerMask.topLeft == .layerMinXMaxYCorner)
        #expect(CACornerMask.topRight == .layerMaxXMaxYCorner)
        #expect(CACornerMask.bottomRight == .layerMaxXMinYCorner)
        #expect(CACornerMask.bottomLeft == .layerMinXMinYCorner)
        #expect(CACornerMask.all == [.topLeft, .topRight, .bottomLeft, .bottomRight])
    }
}
