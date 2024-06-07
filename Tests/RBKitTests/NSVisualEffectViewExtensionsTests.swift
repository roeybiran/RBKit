import XCTest
@testable import RBKit

final class NSVisualEffectViewExtensionsTests: XCTestCase {
  func test1() {
    let sut = NSVisualEffectView.dockStyle()
    XCTAssertEqual(sut.blendingMode, .behindWindow)
    XCTAssertEqual(sut.material, .fullScreenUI)
  }
}
