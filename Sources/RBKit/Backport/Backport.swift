import SwiftUI

// MARK: - Backport

// https://davedelong.com/blog/2021/10/09/simplifying-backwards-compatibility-in-swift/
// https://www.ralfebert.com/swiftui/new-ios-view-modifiers-with-older-deployment-target/
// https://github.com/shaps80/SwiftUIBackports

public struct Backport<Content> {
  public let content: Content

  public init(_ content: Content) {
    self.content = content
  }
}

extension View {
  public var backport: Backport<Self> { Backport(self) }
}
