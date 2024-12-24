import AppKit
import CustomDump
import Testing

@testable import RBKit

// MARK: - NSCollectionViewExtensionsTests

@MainActor
struct NSCollectionViewExtensionsTests {

  @Test
  func test1() {
    let sut = MockCollectionView()
    sut.register(supplementary: MockViewElement.self)

    #expect(sut.calls.count == 1)
    let c0 = sut.calls[0] as! [Any]
    #expect(c0.count == 3)
    #expect(String(describing: c0[0]) == "Optional(RBKitTests.MockViewElement)")
    #expect(c0[1] as! String == "MockViewElement")
    #expect(c0[2] as! NSUserInterfaceItemIdentifier == .init(rawValue: "MockViewElement"))
  }

  @Test
  func test2() {
    let sut = MockCollectionView()
    sut.register(item: MockViewItem.self)

    #expect(sut.calls.count == 1)
    let c0 = sut.calls[0] as! [Any]
    #expect(c0.count == 2)
    #expect(String(describing: c0[0]) == "Optional(RBKitTests.MockViewItem)")
    #expect(c0[1] as! NSUserInterfaceItemIdentifier == .init(rawValue: "MockViewItem"))
  }

  @Test
  func test3() {
    let sut = MockCollectionView()
    _ = sut.makeSupplementaryView(ofKind: MockViewElement.self, for: [0])

    #expect(sut.calls.count == 1)
    let c0 = sut.calls[0] as! [Any]
    #expect(c0.count == 3)
    #expect(c0[0] as! String == "MockViewElement")
    #expect(c0[1] as! NSUserInterfaceItemIdentifier == .init(rawValue: "MockViewElement"))
    #expect(c0[2] as! IndexPath == [0])
  }

  @Test
  func test4() {
    let sut = MockCollectionView()
    _ = sut.makeItem(of: MockViewElement.self, for: [0, 0])

    #expect(sut.calls.count == 1)
    let c0 = sut.calls[0] as! [Any]
    #expect(c0.count == 2)
    #expect(c0[0] as! NSUserInterfaceItemIdentifier == MockViewElement.userInterfaceIdentifier)
    #expect(c0[1] as! IndexPath == [0, 0])
  }

}

// MARK: - MockCollectionView

private class MockCollectionView: NSCollectionView {
  var calls = [Any]()

  override func register(
    _ viewClass: AnyClass?,
    forSupplementaryViewOfKind kind: NSCollectionView.SupplementaryElementKind,
    withIdentifier identifier: NSUserInterfaceItemIdentifier)
  {
    calls.append([viewClass as Any, kind, identifier])
  }

  override func register(
    _ itemClass: AnyClass?, forItemWithIdentifier identifier: NSUserInterfaceItemIdentifier)
  {
    calls.append([itemClass as Any, identifier])
  }

  override func makeSupplementaryView(
    ofKind elementKind: NSCollectionView.SupplementaryElementKind,
    withIdentifier identifier: NSUserInterfaceItemIdentifier,
    for indexPath: IndexPath)
    -> NSView
  {
    calls.append([elementKind, identifier, indexPath])
    return super.makeSupplementaryView(
      ofKind: elementKind, withIdentifier: identifier, for: indexPath)
  }

  override func makeItem(
    withIdentifier identifier: NSUserInterfaceItemIdentifier,
    for indexPath: IndexPath)
    -> NSCollectionViewItem
  {
    calls.append([identifier, indexPath])
    return MockViewItem()
  }
}

// MARK: - MockViewItem

class MockViewItem: NSCollectionViewItem { }

// MARK: - MockViewElement

class MockViewElement: NSView, NSCollectionViewElement { }
