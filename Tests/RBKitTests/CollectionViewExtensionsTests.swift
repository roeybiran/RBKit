import CustomDump
import XCTest

@testable import RBKit

// MARK: - CollectionView

class CollectionView: NSCollectionView {
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
}

// MARK: - TestView

class TestView: NSView, NSCollectionViewElement { }

// MARK: - TestItem

class TestItem: NSCollectionViewItem { }

// MARK: - NSCollectionViewTests

final class NSCollectionViewTests: XCTestCase {

  func test1() {
    let sut = CollectionView()
    sut.register(supplementary: TestView.self)

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 3)
    XCTAssertEqual(String(describing: c0[0]), "Optional(RBKitTests.TestView)")
    XCTAssertEqual(c0[1] as! String, "TestView")
    XCTAssertEqual(c0[2] as! NSUserInterfaceItemIdentifier, .init(rawValue: "TestView"))
  }

  func test2() {
    let sut = CollectionView()
    sut.register(item: TestItem.self)

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 2)
    XCTAssertEqual(String(describing: c0[0]), "Optional(RBKitTests.TestItem)")
    XCTAssertEqual(c0[1] as! NSUserInterfaceItemIdentifier, .init(rawValue: "TestItem"))
  }

  func test3() {
    let sut = CollectionView()
    _ = sut.makeSupplementaryView(ofKind: TestView.self, for: [0])

    XCTAssertEqual(sut.calls.count, 1)
    let c0 = sut.calls[0] as! [Any]
    XCTAssertEqual(c0.count, 3)
    XCTAssertEqual(c0[0] as! String, "TestView")
    XCTAssertEqual(c0[1] as! NSUserInterfaceItemIdentifier, .init(rawValue: "TestView"))
    XCTAssertEqual(c0[2] as! IndexPath, [0])
  }
}
