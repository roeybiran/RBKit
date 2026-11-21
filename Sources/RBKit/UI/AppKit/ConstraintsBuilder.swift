import AppKit

// MARK: - ConstraintsBuilder

// https://www.avanderlee.com/swift/result-builders/

@resultBuilder
public enum ConstraintsBuilder {
  public static func buildBlock(_ components: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
    components.flatMap { $0 }
  }

  public static func buildExpression(_ expression: NSLayoutConstraint) -> [NSLayoutConstraint] {
    [expression]
  }

  public static func buildExpression(_ expression: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
    expression
  }
}

extension NSLayoutConstraint {
  public static func activate(@ConstraintsBuilder constraints: () -> [NSLayoutConstraint]) {
    Self.activate(constraints())
  }
}
