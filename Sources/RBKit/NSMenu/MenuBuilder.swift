import Cocoa

@resultBuilder
public enum MenuBuilder {
  public static func buildBlock(_ components: NSMenuItem...) -> [NSMenuItem] {
    components
  }

  public static func buildArray(_ components: [[NSMenuItem]]) -> [NSMenuItem] {
    components.flatMap { $0 }
  }
}
