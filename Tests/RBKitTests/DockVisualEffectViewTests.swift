import XCTest
@testable import RBKit

final class DockVisualEffectViewTests: XCTestCase {
  func test() {
    let sut = DockVisualEffectView()
    XCTAssertEqual(sut.blendingMode, .behindWindow)
    XCTAssertEqual(sut.material, .fullScreenUI)
  }
}
