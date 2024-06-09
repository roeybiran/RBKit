import Carbon
import CustomDump
import XCTest
@testable import RBKit

final class NSObjectExtensionsTests: XCTestCase {
  func test_NSObject_UIIdentifier() {
    XCTAssertEqual(NSObject.userInterfaceIdentifier, "NSObject")
    XCTAssertEqual(NSView.userInterfaceIdentifier, "NSView")
    class MainCell: NSTableCellView { }
    XCTAssertEqual(MainCell.userInterfaceIdentifier, "MainCell")
  }

  func test_NSObject_dotSyntaxSettable() {
    let view = NSView()
    XCTAssertEqual(view.identifier, nil)
    view.set(\.identifier, to: "foo")
    XCTAssertEqual(view.identifier, "foo")
  }
}
