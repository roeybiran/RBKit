import Cocoa

@resultBuilder
public enum MenuBuilder {
  public static func buildBlock(_ components: [NSMenuItem]...) -> [NSMenuItem] {
    components.flatMap { $0 }
  }

  public static func buildExpression(_ expression: NSMenuItem) -> [NSMenuItem] {
    [expression]
  }

  public static func buildExpression(_ expression: [NSMenuItem]) -> [NSMenuItem] {
    expression
  }
}
