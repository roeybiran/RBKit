import Foundation

extension Bundle {
  open class Mock: Bundle, @unchecked Sendable {
    public var _bundleIdentifier: String?

    open override var bundleIdentifier: String? {
      get { _bundleIdentifier }
      set { _bundleIdentifier = newValue }
    }
  }
}
