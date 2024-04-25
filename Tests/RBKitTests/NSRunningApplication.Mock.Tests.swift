import XCTest
@testable import RBKit

final class NSRunningApplicationMockTests: XCTestCase {
  func test() {
    let app = NSRunningApplication.Mock()
    XCTAssertEqual(app.activationPolicy, .regular)
    app._activationPolicy = .prohibited
    XCTAssertEqual(app.activationPolicy, .prohibited)
    XCTAssertEqual(app.isHidden, false)
    XCTAssertEqual(NSRunningApplication.Mock(_isHidden: true).isHidden, true)
  }
}
