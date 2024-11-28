import Testing
import AppKit

@testable import RBKit

struct NSRunningApplicationMockTests {
  @Test func test() {
    let app = NSRunningApplication.Mock()
    #expect(app.activationPolicy == .regular)
    app._activationPolicy = .prohibited
    #expect(app.activationPolicy == .prohibited)
    #expect(app.isHidden == false)
    #expect(NSRunningApplication.Mock(_isHidden: true).isHidden == true)
  }
}
