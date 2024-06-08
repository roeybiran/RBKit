import Foundation

extension NSNotification.Name: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self = .init(value)
  }
}
