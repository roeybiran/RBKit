import Foundation

extension Bundle {
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
