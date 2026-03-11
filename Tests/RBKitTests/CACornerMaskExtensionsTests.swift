import QuartzCore
import Testing

@testable import RBKit

struct CACornerMaskTests {
  @Test
  func `topLeft, should equal layerMinXMaxYCorner`() {
    #expect(CACornerMask.topLeft == .layerMinXMaxYCorner)
  }

  @Test
  func `topRight, should equal layerMaxXMaxYCorner`() {
    #expect(CACornerMask.topRight == .layerMaxXMaxYCorner)
  }

  @Test
  func `bottomRight, should equal layerMaxXMinYCorner`() {
    #expect(CACornerMask.bottomRight == .layerMaxXMinYCorner)
  }

  @Test
  func `bottomLeft, should equal layerMinXMinYCorner`() {
    #expect(CACornerMask.bottomLeft == .layerMinXMinYCorner)
  }

  @Test
  func `all, should equal all corners`() {
    #expect(CACornerMask.all == [.topLeft, .topRight, .bottomLeft, .bottomRight])
  }
}
