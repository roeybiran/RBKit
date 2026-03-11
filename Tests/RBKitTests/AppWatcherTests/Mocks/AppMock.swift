import AppKit
import RBKit
import RBKitTestSupport

/// Equates by PID, for easier testing.
final class AppMock: NSRunningApplication.Mock {
  override func isEqual(_ object: Any?) -> Bool {
    if let object = object as? AppMock {
      _processIdentifier == object.processIdentifier
    } else {
      false
    }
  }
}
