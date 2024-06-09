import CustomDump
import XCTest

@testable import RBKit

// MARK: - NSCollectionViewTests

final class NSCollectionViewTests: XCTestCase {

  func test1() {
    let sut = MockCollectionView()
    sut.register(supplementary: MockViewElement.self)

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 3)
    XCTAssertEqual(String(describing: c0[0]), "Optional(RBKitTests.MockViewElement)")
    XCTAssertEqual(c0[1] as! String, "MockViewElement")
    XCTAssertEqual(c0[2] as! NSUserInterfaceItemIdentifier, .init(rawValue: "MockViewElement"))
  }

  func test2() {
    let sut = MockCollectionView()
    sut.register(item: MockViewItem.self)

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 2)
    XCTAssertEqual(String(describing: c0[0]), "Optional(RBKitTests.MockViewItem)")
    XCTAssertEqual(c0[1] as! NSUserInterfaceItemIdentifier, .init(rawValue: "MockViewItem"))
  }

  func test3() {
    let sut = MockCollectionView()
    _ = sut.makeSupplementaryView(ofKind: MockViewElement.self, for: [0])

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 3)
    XCTAssertEqual(c0[0] as! String, "MockViewElement")
    XCTAssertEqual(c0[1] as! NSUserInterfaceItemIdentifier, .init(rawValue: "MockViewElement"))
    XCTAssertEqual(c0[2] as! IndexPath, [0])
  }

  func test4() {
    let sut = MockCollectionView()
    _ = sut.makeItem(of: MockViewElement.self, for: [0, 0])

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 2)
    XCTAssertEqual(c0[0] as! NSUserInterfaceItemIdentifier, MockViewElement.userInterfaceIdentifier)
    XCTAssertEqual(c0[1] as! IndexPath, [0, 0])
  }

}

private class MockCollectionView: NSCollectionView {
  var calls = [Any]()

  override func register(
    _ viewClass: AnyClass?,
    forSupplementaryViewOfKind kind: NSCollectionView.SupplementaryElementKind,
    withIdentifier identifier: NSUserInterfaceItemIdentifier)
  {
    calls.append([viewClass as Any, kind, identifier])
  }

  override func register(_ itemClass: AnyClass?, forItemWithIdentifier identifier: NSUserInterfaceItemIdentifier) {
    calls.append([itemClass as Any, identifier])
  }

  override func makeSupplementaryView(
    ofKind elementKind: NSCollectionView.SupplementaryElementKind,
    withIdentifier identifier: NSUserInterfaceItemIdentifier,
    for indexPath: IndexPath)
  -> NSView
  {
    calls.append([elementKind, identifier, indexPath])
    return super.makeSupplementaryView(ofKind: elementKind, withIdentifier: identifier, for: indexPath)
  }

  override func makeItem(withIdentifier identifier: NSUserInterfaceItemIdentifier, for indexPath: IndexPath) -> NSCollectionViewItem {
    calls.append([identifier, indexPath])
    return MockViewItem()
  }
}

class MockViewItem: NSCollectionViewItem { }

class MockViewElement: NSView, NSCollectionViewElement { }
