import AppKit

// MARK: - NSUserInterfaceItemIdentifier + ExpressibleByStringLiteral

extension NSUserInterfaceItemIdentifier: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }
}

// MARK: - NSUserInterfaceItemIdentifier + ExpressibleByStringInterpolation

extension NSUserInterfaceItemIdentifier: ExpressibleByStringInterpolation {
  public init(stringInterpolation: DefaultStringInterpolation) {
    self.init(stringInterpolation.description)
  }
}
