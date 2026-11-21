import AppKit
import RBKit
import RBKitTestSupport

/// Equates by PID, for easier testing.
// swiftlint:disable:next no_unchecked_sendable -- NSRunningApplication.Mock already inherits @unchecked Sendable, and Swift requires this subclass to restate that inherited conformance ("must restate inherited '@unchecked Sendable' conformance").
final class AppMock: NSRunningApplication.Mock, @unchecked Sendable {
  override func isEqual(_ object: Any?) -> Bool {
    if let object = object as? AppMock {
      _processIdentifier == object.processIdentifier
    } else {
      false
    }
  }
}
