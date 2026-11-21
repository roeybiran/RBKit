import AppKit
import Testing

@testable import RBKit

@MainActor
struct NSTableViewTests {
  @Test
  func `makeView ofType:, should use type name as identifier`() {
    let tableView = NSTableView()

    final class FooView: NSView { }

    let view = tableView.makeView(ofType: FooView.self)

    #expect(view.identifier == .init("FooView"))
  }

  @Test
  func `makeView ofType:, with GroupRowCell, should create cell with label textField`() {
    let tableView = NSTableView()

    let view = tableView.makeView(ofType: GroupRowCell.self)

    #expect(view.identifier == .init("GroupRowCell"))
    #expect(view.textField != nil)
  }
}
