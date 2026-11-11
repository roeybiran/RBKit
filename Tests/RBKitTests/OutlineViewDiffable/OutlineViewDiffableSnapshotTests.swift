import IdentifiedCollections
import Testing

@testable import RBKit

struct `OutlineViewDiffableSnapshot Tests` {

  // MARK: Internal

  @Test
  func `append(items:) should materialize root and descendant lookups`() {
    let child = TestNode(id: 1)
    let sibling = TestNode(id: 2)
    let root = TestNode(id: 0, children: [child, sibling])
    let trailing = TestNode(id: 3)
    var snapshot = OutlineViewDiffableSnapshot<TestNode>()

    snapshot.append(items: [root, trailing])

    #expect(snapshot[0].value == root)
    #expect(snapshot[1].value == trailing)
    #expect(snapshot.children(of: nil).map(\.value.id) == [0, 3])
    #expect(snapshot.children(parentID: 0).map(\.value.id) == [1, 2])
    #expect(snapshot.item(id: 2)?.value == sibling)
    #expect(snapshot.childIndex(id: 2) == 1)
    #expect(snapshot.parentID(id: 2) == 0)
    #expect(snapshot.ids == [0, 1, 2, 3])
    #expect(snapshot.orderedParentIDs == [nil, 0, 1, 2, 3])
  }

  @Test
  func `append(items:) should rebuild lookups from the latest tree`() {
    var snapshot = OutlineViewDiffableSnapshot<TestNode>()

    snapshot.append(items: [.init(id: 0, children: [.init(id: 1)])])
    let staleRoot = snapshot[0]

    snapshot.append(items: [.init(id: 0, children: [.init(id: 2)])])

    #expect(snapshot.children(of: staleRoot).map(\.value.id) == [2])
    #expect(snapshot.item(id: 1) == nil)
    #expect(snapshot.item(id: 2)?.value == .init(id: 2))
    #expect(snapshot.ids == [0, 2])
  }

  @Test
  func `hasSameValues(as:) should compare root item values`() {
    var snapshot = OutlineViewDiffableSnapshot<TestNode>()
    var sameValues = OutlineViewDiffableSnapshot<TestNode>()
    var differentValues = OutlineViewDiffableSnapshot<TestNode>()

    snapshot.append(items: [.init(id: 0, version: 0), .init(id: 1, version: 0)])
    sameValues.append(items: [.init(id: 0, version: 0), .init(id: 1, version: 0)])
    differentValues.append(items: [.init(id: 0, version: 1), .init(id: 1, version: 0)])

    #expect(snapshot.hasSameValues(as: sameValues))
    #expect(snapshot.hasSameValues(as: differentValues) == false)
  }

  // MARK: Private

  private struct TestNode: Equatable, Hashable, Identifiable, TreeNodeProtocol {
    init(id: Int, version: Int = 0, children: [Self] = []) {
      self.id = id
      self.version = version
      self.children = .init(uniqueElements: children)
    }

    var id: Int
    var version: Int
    var children = IdentifiedArrayOf<Self>()
  }
}
