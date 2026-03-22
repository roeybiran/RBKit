import Foundation

extension Bundle {
  // swiftlint:disable:next no_unchecked_sendable -- Bundle already inherits @unchecked Sendable from Foundation, and Swift requires subclasses to restate that inherited conformance ("must restate inherited '@unchecked Sendable' conformance").
  open class Mock: Bundle, @unchecked Sendable {

    // MARK: Open

    open override var bundleIdentifier: String? {
      get { _bundleIdentifier }
      set { _bundleIdentifier = newValue }
    }

    // MARK: Public

    public var _bundleIdentifier: String?

  }
}
