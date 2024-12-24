import AppKit
import CustomDump
import Testing

@testable import RBKit

@MainActor
struct NSObjectExtensionsTests {
  @Test
  func test_NSObject_UIIdentifier() {
    #expect(NSObject.userInterfaceIdentifier == "NSObject")
    #expect(NSView.userInterfaceIdentifier == "NSView")
    class MainCell: NSTableCellView { }
    #expect(MainCell.userInterfaceIdentifier == "MainCell")
  }

  @Test
  func test_NSObject_dotSyntaxSettable() {
    let view = NSView()
    #expect(view.identifier == nil)
    view.set(\.identifier, to: "foo")
    #expect(view.identifier == "foo")
  }
}
