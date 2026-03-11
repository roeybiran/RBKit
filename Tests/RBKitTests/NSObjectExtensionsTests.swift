import AppKit
import Testing

@testable import RBKit

@MainActor
struct NSObjectTests {
  @Test
  func `set, with keyPath, should update value`() {
    let view = NSView()

    #expect(view.identifier == nil)

    view.set(\.identifier, to: .init("foo"))

    #expect(view.identifier == .init("foo"))
  }
}
