import Cocoa

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
