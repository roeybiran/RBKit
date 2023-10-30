import Cocoa

extension NSLayoutConstraint {
  public static func activate(@ConstraintsBuilder constraints: () -> [NSLayoutConstraint]) {
    Self.activate(constraints())
  }
}

extension [NSLayoutConstraint] {
  public func activate() {
    NSLayoutConstraint.activate(self)
  }
}
