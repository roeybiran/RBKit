import AppKit
import IdentifiedCollections
import Testing

@testable import RBKit

@Suite(.serialized)
@MainActor
struct `OutlineViewDiffableDataSource Tests` {

  // MARK: Internal

  @Test
  func `apply(_:animatingDifferences:completion:) with appended root item, should insert at the target index`() {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let firstNode = TestNode(id: 0)

      var initialSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      initialSnapshot.append(items: [firstNode])
      dataSource.apply(initialSnapshot, animatingDifferences: false)

      outlineView.reset()
      outlineView.numberOfChildrenByParentID[TestOutlineView.rootParentID] = 1
      outlineView.parentIDByItemID[firstNode.id] = TestOutlineView.rootParentID
      outlineView.childIndexByItemID[firstNode.id] = 0

      var updatedSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      updatedSnapshot.append(items: [firstNode, TestNode(id: 1)])

      dataSource.apply(updatedSnapshot, animatingDifferences: true)

      #expect(
        outlineView.insertedOperations == [
          .init(indexes: [1], parentID: TestOutlineView.rootParentID)
        ]
      )
      #expect(outlineView.reloadDataCallCount == 0)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with unchanged snapshot, should call completion with false`() {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let node = TestNode(id: 0)

      var snapshot = OutlineViewDiffableSnapshot<TestNode>()
      snapshot.append(items: [node])
      dataSource.apply(snapshot, animatingDifferences: false)

      outlineView.reset()

      var completionArguments = [Bool]()
      dataSource.apply(snapshot, animatingDifferences: true) { didApply in
        completionArguments.append(didApply)
      }

      #expect(completionArguments == [false])
      #expect(outlineView.beginUpdatesCallCount == 0)
      #expect(outlineView.endUpdatesCallCount == 0)
      #expect(outlineView.reloadDataCallCount == 0)
      #expect(dataSource.itemIdentifier(for: node.id) == node)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with unchanged child position outside materialized rows, should not hard reload`(
  ) {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let child = TestNode(id: 1)
      let app = TestNode(id: 0, children: [child])

      var initialSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      initialSnapshot.append(items: [app])
      dataSource.apply(initialSnapshot, animatingDifferences: false)

      outlineView.reset()
      outlineView.numberOfChildrenByParentID[TestOutlineView.rootParentID] = 1
      outlineView.parentIDByItemID[app.id] = TestOutlineView.rootParentID
      outlineView.childIndexByItemID[app.id] = 0

      var updatedApp = app
      updatedApp.version = 1

      var updatedSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      updatedSnapshot.append(items: [updatedApp])

      dataSource.apply(updatedSnapshot, animatingDifferences: true)

      #expect(outlineView.beginUpdatesCallCount == 1)
      #expect(outlineView.endUpdatesCallCount == 1)
      #expect(outlineView.reloadDataCallCount == 0)
      #expect(dataSource.itemIdentifier(for: app.id) == updatedApp)
      #expect(dataSource.itemIdentifier(for: child.id) == child)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with removed sibling before retained root item, should not treat it as a move`(
  ) {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let firstNode = TestNode(id: 0)
      let removedNode = TestNode(id: 1)
      let retainedNode = TestNode(id: 2)

      var initialSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      initialSnapshot.append(items: [firstNode, removedNode, retainedNode])
      dataSource.apply(initialSnapshot, animatingDifferences: false)

      outlineView.reset()
      outlineView.numberOfChildrenByParentID[TestOutlineView.rootParentID] = 3
      outlineView.parentIDByItemID[firstNode.id] = TestOutlineView.rootParentID
      outlineView.parentIDByItemID[removedNode.id] = TestOutlineView.rootParentID
      outlineView.parentIDByItemID[retainedNode.id] = TestOutlineView.rootParentID
      outlineView.childIndexByItemID[firstNode.id] = 0
      outlineView.childIndexByItemID[removedNode.id] = 1
      outlineView.childIndexByItemID[retainedNode.id] = 2

      var updatedSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      updatedSnapshot.append(items: [firstNode, retainedNode])

      dataSource.apply(updatedSnapshot, animatingDifferences: true)

      #expect(outlineView.beginUpdatesCallCount == 1)
      #expect(outlineView.endUpdatesCallCount == 1)
      #expect(outlineView.reloadDataCallCount == 0)
      #expect(outlineView.moveOperations.isEmpty)
      #expect(
        outlineView.removedOperations == [
          .init(indexes: [1], parentID: TestOutlineView.rootParentID)
        ]
      )
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with removed subtree whose child is not materialized, should remove only the subtree root`(
  ) {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let child = TestNode(id: 1)
      let app = TestNode(id: 0, children: [child])

      var initialSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      initialSnapshot.append(items: [app])
      dataSource.apply(initialSnapshot, animatingDifferences: false)

      outlineView.reset()
      outlineView.numberOfChildrenByParentID[TestOutlineView.rootParentID] = 1
      outlineView.parentIDByItemID[app.id] = TestOutlineView.rootParentID
      outlineView.childIndexByItemID[app.id] = 0

      var updatedSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      updatedSnapshot.append(items: [])

      dataSource.apply(updatedSnapshot, animatingDifferences: true)

      #expect(outlineView.beginUpdatesCallCount == 1)
      #expect(outlineView.endUpdatesCallCount == 1)
      #expect(outlineView.reloadDataCallCount == 0)
      #expect(outlineView.moveOperations.isEmpty)
      #expect(
        outlineView.removedOperations == [
          .init(indexes: [0], parentID: TestOutlineView.rootParentID)
        ]
      )
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with moved root item and removed sibling, should animate move and remove without hard reload`(
  ) {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let firstNode = TestNode(id: 0)
      let removedNode = TestNode(id: 1)
      let movedNode = TestNode(id: 2)

      var initialSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      initialSnapshot.append(items: [firstNode, removedNode, movedNode])
      dataSource.apply(initialSnapshot, animatingDifferences: false)

      outlineView.reset()
      outlineView.numberOfChildrenByParentID[TestOutlineView.rootParentID] = 3
      outlineView.parentIDByItemID[firstNode.id] = TestOutlineView.rootParentID
      outlineView.parentIDByItemID[removedNode.id] = TestOutlineView.rootParentID
      outlineView.parentIDByItemID[movedNode.id] = TestOutlineView.rootParentID
      outlineView.childIndexByItemID[firstNode.id] = 0
      outlineView.childIndexByItemID[removedNode.id] = 1
      outlineView.childIndexByItemID[movedNode.id] = 2

      var updatedSnapshot = OutlineViewDiffableSnapshot<TestNode>()
      updatedSnapshot.append(items: [movedNode, firstNode])

      dataSource.apply(updatedSnapshot, animatingDifferences: true)

      #expect(outlineView.beginUpdatesCallCount == 1)
      #expect(outlineView.endUpdatesCallCount == 1)
      #expect(outlineView.reloadDataCallCount == 0)
      #expect(outlineView.moveOperations.isEmpty == false)
      #expect(outlineView.removedOperations.isEmpty == false)
      #expect(dataSource.itemIdentifier(for: movedNode.id) == movedNode)
      #expect(dataSource.itemIdentifier(for: firstNode.id) == firstNode)
      #expect(dataSource.itemIdentifier(for: removedNode.id) == nil)
      #expect(dataSource.outlineView(outlineView, numberOfChildrenOfItem: nil as Any?) == 2)
    }
  }

  @Test
  func `outlineView(_:child:ofItem:) with impossible child index, should return the fallback item`() {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let firstNode = TestNode(id: 0)
      let secondNode = TestNode(id: 1)

      var snapshot = OutlineViewDiffableSnapshot<TestNode>()
      snapshot.append(items: [firstNode, secondNode])
      dataSource.apply(snapshot, animatingDifferences: false)

      let child = dataSource.outlineView(outlineView, child: 99, ofItem: nil as Any?)

      #expect(dataSource.isFallbackItem(child))
      #expect(dataSource.outlineView(outlineView, numberOfChildrenOfItem: child) == 0)
      #expect(dataSource.outlineView(outlineView, isItemExpandable: child) == false)
      #expect(dataSource.fallbackItemRowHeight == 1)
    }
  }

  @Test
  func `outlineView(_:child:ofItem:) with empty tree after serving a child, should return the fallback item`() {
    withOutlineViewDiffableTestLock {
      let outlineView = TestOutlineView()
      let dataSource = OutlineViewDiffableDataSource<TestNode>(outlineView: outlineView)
      let firstNode = TestNode(id: 0)
      let secondNode = TestNode(id: 1)

      var snapshot = OutlineViewDiffableSnapshot<TestNode>()
      snapshot.append(items: [firstNode, secondNode])
      dataSource.apply(snapshot, animatingDifferences: false)

      _ = dataSource.outlineView(outlineView, child: 1, ofItem: nil as Any?)

      var emptySnapshot = OutlineViewDiffableSnapshot<TestNode>()
      emptySnapshot.append(items: [])
      dataSource.apply(emptySnapshot, animatingDifferences: false)

      let child = dataSource.outlineView(outlineView, child: 0, ofItem: nil as Any?)

      #expect(dataSource.isFallbackItem(child))
      #expect(dataSource.outlineView(outlineView, numberOfChildrenOfItem: child) == 0)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with deallocated outline view, should update snapshot and report didApply true`(
  ) {
    withOutlineViewDiffableTestLock {
      let dataSource: OutlineViewDiffableDataSource<TestNode> = autoreleasepool {
        OutlineViewDiffableDataSource(outlineView: TestOutlineView())
      }
      let node = TestNode(id: 0)

      var snapshot = OutlineViewDiffableSnapshot<TestNode>()
      snapshot.append(items: [node])

      var completionArguments = [Bool]()
      dataSource.apply(snapshot, animatingDifferences: true) { didApply in
        completionArguments.append(didApply)
      }

      #expect(completionArguments == [true])
      #expect(dataSource.itemIdentifier(for: node.id) == node)
      #expect(dataSource.row(for: node) == nil)
    }
  }

  @Test
  func `init(outlineView:) should set the outline view data source`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()

      #expect(harness.outlineView.dataSource === harness.dataSource)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with empty snapshot, should keep the outline view empty`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      nonisolated(unsafe) var completionArguments = [Bool]()

      harness.dataSource.apply(harness.makeSnapshot([]), animatingDifferences: true) { didApply in
        completionArguments.append(didApply)
      }

      #expect(completionArguments == [false])
      #expect(harness.outlineView.numberOfRows == 0)
      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: nil as Any?) == 0)
      #expect(harness.dataSource.itemIdentifier(for: 999) == nil)
      #expect(harness.dataSource.itemIdentifier(forRow: -1) == nil)
      #expect(harness.dataSource.itemIdentifier(forRow: 0) == nil)
      #expect(harness.dataSource.row(for: .init(id: 999)) == nil)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with flat root items, should materialize visible preorder and row round trips`(
  ) throws {
    try withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let nodes = [
        OutlineViewDiffableTestNode(id: 0),
        OutlineViewDiffableTestNode(id: 1),
        OutlineViewDiffableTestNode(id: 2),
      ]

      harness.dataSource.apply(harness.makeSnapshot(nodes), animatingDifferences: false)

      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: nil as Any?) == 3)
      #expect(harness.visibleIDs() == [0, 1, 2])

      for row in 0..<nodes.count {
        let node = try #require(harness.dataSource.itemIdentifier(forRow: row))
        #expect(node == nodes[row])
        #expect(harness.dataSource.row(for: node) == row)
        #expect(harness.dataSource.itemIdentifier(for: node.id) == node)
      }
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with nested tree, should materialize nested children and counts`() throws {
    try withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let sidebar = OutlineViewDiffableTestNode(
        id: 0,
        children: [
          .init(id: 1),
          .init(id: 2, children: [.init(id: 3)]),
        ],
      )
      let footer = OutlineViewDiffableTestNode(id: 4)

      harness.dataSource.apply(harness.makeSnapshot([sidebar, footer]), animatingDifferences: false)
      harness.expandAllItems()

      #expect(harness.visibleIDs() == [0, 1, 2, 3, 4])
      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: nil as Any?) == 2)

      let rootItem = try #require(harness.outlineView.item(atRow: 0))
      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: rootItem) == 2)

      let firstChild = harness.dataSource.outlineView(harness.outlineView, child: 0, ofItem: rootItem)
      let secondChild = harness.dataSource.outlineView(harness.outlineView, child: 1, ofItem: rootItem)
      let firstChildRow = try #require(harness.dataSource.row(for: .init(id: 1)))
      let secondChildRow = try #require(harness.dataSource.row(for: .init(id: 2)))

      #expect(harness.dataSource.itemIdentifier(forRow: firstChildRow) == .init(id: 1))
      #expect(harness.dataSource.itemIdentifier(forRow: secondChildRow) == .init(id: 2, children: [.init(id: 3)]))
      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: firstChild) == 0)
      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: secondChild) == 1)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with insertions, should update the visible tree without fallback reload`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let root = OutlineViewDiffableTestNode(id: 1, children: [.init(id: 10)])
      let trailing = OutlineViewDiffableTestNode(id: 5)

      harness.dataSource.apply(harness.makeSnapshot([root, trailing]), animatingDifferences: false)
      harness.expandAllItems()
      harness.resetOperationLog()

      let updatedRoot = OutlineViewDiffableTestNode(
        id: 1,
        children: [
          .init(id: 9),
          .init(id: 10),
          .init(id: 11),
        ],
      )
      nonisolated(unsafe) var completionArguments = [Bool]()
      harness.dataSource.apply(
        harness.makeSnapshot([
          .init(id: 0),
          updatedRoot,
          .init(id: 3),
          trailing,
          .init(id: 6),
        ]),
        animatingDifferences: true,
      ) { didApply in
        completionArguments.append(didApply)
      }
      harness.expandAllItems()

      #expect(completionArguments == [true])
      #expect(harness.outlineView.reloadDataCallCount == 0)
      #expect(harness.outlineView.insertCallCount > 0)
      #expect(harness.visibleIDs() == [0, 1, 9, 10, 11, 3, 5, 6])
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with deletions, should remove leaves roots and branches`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let nodes = [
        OutlineViewDiffableTestNode(id: 0, children: [.init(id: 1), .init(id: 2)]),
        .init(id: 3),
        .init(id: 4, children: [.init(id: 5)]),
      ]

      harness.dataSource.apply(harness.makeSnapshot(nodes), animatingDifferences: false)
      harness.expandAllItems()
      harness.resetOperationLog()

      harness.dataSource.apply(
        harness.makeSnapshot([.init(id: 0, children: [.init(id: 2)])]),
        animatingDifferences: true,
      )
      harness.expandAllItems()

      #expect(harness.outlineView.reloadDataCallCount == 0)
      #expect(harness.outlineView.removeCallCount > 0)
      #expect(harness.visibleIDs() == [0, 2])
      #expect(harness.dataSource.itemIdentifier(for: 1) == nil)
      #expect(harness.dataSource.itemIdentifier(for: 3) == nil)
      #expect(harness.dataSource.itemIdentifier(for: 4) == nil)
      #expect(harness.dataSource.itemIdentifier(for: 5) == nil)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with reintroduced ids after deletion, should make them queryable again`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let initialNodes = [
        OutlineViewDiffableTestNode(id: 0, children: [.init(id: 1)]),
        .init(id: 2),
      ]

      harness.dataSource.apply(harness.makeSnapshot(initialNodes), animatingDifferences: false)
      harness.expandAllItems()

      harness.dataSource.apply(harness.makeSnapshot([.init(id: 0)]), animatingDifferences: true)
      harness.expandAllItems()

      let reintroducedNodes = [
        OutlineViewDiffableTestNode(id: 0),
        .init(id: 2, children: [.init(id: 3)]),
        .init(id: 4),
      ]
      nonisolated(unsafe) var completionArguments = [Bool]()
      harness.dataSource.apply(harness.makeSnapshot(reintroducedNodes), animatingDifferences: true) { didApply in
        completionArguments.append(didApply)
      }
      harness.expandAllItems()

      #expect(completionArguments == [true])
      #expect(harness.visibleIDs() == [0, 2, 3, 4])
      #expect(harness.dataSource.itemIdentifier(for: 2) == .init(id: 2, children: [.init(id: 3)]))
      #expect(harness.dataSource.itemIdentifier(for: 3) == .init(id: 3))
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with populated snapshot then empty snapshot, should clear rows`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()

      harness.dataSource.apply(
        harness.makeSnapshot([
          .init(id: 0, children: [.init(id: 1)]),
          .init(id: 2),
        ]),
        animatingDifferences: false,
      )
      harness.expandAllItems()

      nonisolated(unsafe) var completionArguments = [Bool]()
      harness.dataSource.apply(harness.makeSnapshot([]), animatingDifferences: true) { didApply in
        completionArguments.append(didApply)
      }

      #expect(completionArguments == [true])
      #expect(harness.outlineView.numberOfRows == 0)
      #expect(harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: nil as Any?) == 0)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with retained value changes and deletions, should keep retained items addressable and delete removed items`(
  ) {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let initialNodes = [
        OutlineViewDiffableTestNode(id: 0, version: 0),
        .init(id: 1, version: 0),
        .init(id: 2, version: 0),
      ]

      harness.dataSource.apply(harness.makeSnapshot(initialNodes), animatingDifferences: false)
      harness.resetOperationLog()

      let updatedNodes = [
        OutlineViewDiffableTestNode(id: 0, version: 1),
        .init(id: 2, version: 2),
      ]
      harness.dataSource.apply(harness.makeSnapshot(updatedNodes), animatingDifferences: true)

      #expect(harness.outlineView.reloadDataCallCount == 0)
      #expect(harness.dataSource.itemIdentifier(for: 0) == .init(id: 0, version: 1))
      #expect(harness.dataSource.itemIdentifier(for: 1) == nil)
      #expect(harness.dataSource.itemIdentifier(for: 2) == .init(id: 2, version: 2))
    }
  }

  @Test
  func
    `apply(_:animatingDifferences:completion:) with moved item and value change, should avoid hard reload`()
  {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let initialNodes = [
        OutlineViewDiffableTestNode(id: 0, version: 0),
        .init(id: 1, version: 0),
        .init(id: 2, version: 0),
      ]

      harness.dataSource.apply(harness.makeSnapshot(initialNodes), animatingDifferences: false)
      harness.resetOperationLog()

      let updatedNodes = [
        OutlineViewDiffableTestNode(id: 2, version: 1),
        .init(id: 0, version: 0),
        .init(id: 1, version: 0),
      ]
      harness.dataSource.apply(harness.makeSnapshot(updatedNodes), animatingDifferences: true)

      #expect(harness.outlineView.reloadDataCallCount == 0)
      #expect(harness.outlineView.moveCallCount > 0)
      #expect(harness.outlineView.noteHeightOfRowsCallCount > 0)
      #expect(harness.dataSource.itemIdentifier(for: 2) == .init(id: 2, version: 1))
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with reordered and reparented items, should match the final preorder`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let initialNodes = [
        OutlineViewDiffableTestNode(id: 0, children: [.init(id: 1)]),
        .init(id: 2, children: [.init(id: 3), .init(id: 4)]),
      ]

      harness.dataSource.apply(harness.makeSnapshot(initialNodes), animatingDifferences: false)
      harness.expandAllItems()
      harness.resetOperationLog()

      let updatedNodes = [
        OutlineViewDiffableTestNode(id: 2, children: [.init(id: 3), .init(id: 1)]),
        .init(id: 0, children: [.init(id: 4)]),
      ]
      harness.dataSource.apply(harness.makeSnapshot(updatedNodes), animatingDifferences: true)
      harness.expandAllItems()

      #expect(harness.outlineView.reloadDataCallCount == 0)
      #expect(harness.outlineView.moveCallCount > 0)
      #expect(harness.visibleIDs() == [2, 3, 1, 0, 4])
    }
  }

  @Test
  func `outlineView(_:isItemExpandable:) with closure unset set and unknown item, should follow the closure mapping`() throws {
    try withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let root = OutlineViewDiffableTestNode(id: 0, children: [.init(id: 1)])

      harness.dataSource.apply(harness.makeSnapshot([root]), animatingDifferences: false)
      harness.expandAllItems()
      harness.dataSource.isExpandable = nil

      let rootItem = try #require(harness.outlineView.item(atRow: 0))
      let leafItem = try #require(harness.outlineView.item(atRow: 1))

      #expect(harness.dataSource.outlineView(harness.outlineView, isItemExpandable: rootItem) == false)
      #expect(harness.dataSource.outlineView(harness.outlineView, isItemExpandable: leafItem) == false)

      harness.dataSource.isExpandable = { !$0.children.isEmpty }

      #expect(harness.dataSource.outlineView(harness.outlineView, isItemExpandable: rootItem) == true)
      #expect(harness.dataSource.outlineView(harness.outlineView, isItemExpandable: leafItem) == false)
      #expect(harness.dataSource.outlineView(harness.outlineView, isItemExpandable: NSObject()) == false)
    }
  }

  @Test
  func `outlineView(_:validateDrop:proposedItem:proposedChildIndex:) and outlineView(_:acceptDrop:item:childIndex:) without closures, should return default values`(
  ) {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let draggingInfo = OutlineViewDiffableDraggingInfoStub(draggingSourceOperationMask: .copy)

      #expect(
        harness.dataSource.outlineView(
          harness.outlineView,
          validateDrop: draggingInfo,
          proposedItem: nil,
          proposedChildIndex: 0,
        ) == []
      )
      #expect(
        harness.dataSource.outlineView(
          harness.outlineView,
          acceptDrop: draggingInfo,
          item: nil,
          childIndex: 0,
        ) == false
      )
    }
  }

  @Test
  func `outlineView(_:validateDrop:proposedItem:proposedChildIndex:) with root level drop, should forward nil item and index`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let draggingInfo = OutlineViewDiffableDraggingInfoStub(draggingSourceOperationMask: .move)
      nonisolated(unsafe) var forwardedItem: OutlineViewDiffableTestNode?
      nonisolated(unsafe) var forwardedIndex: Int?
      nonisolated(unsafe) var forwardedOutlineView: NSOutlineView?

      harness.dataSource.validateDrop = { outlineView, info, item, index in
        forwardedOutlineView = outlineView
        forwardedItem = item
        forwardedIndex = index
        #expect(info === draggingInfo)
        return .move
      }

      let result = harness.dataSource.outlineView(
        harness.outlineView,
        validateDrop: draggingInfo,
        proposedItem: nil,
        proposedChildIndex: 3,
      )

      #expect(result == .move)
      #expect(forwardedOutlineView === harness.outlineView)
      #expect(forwardedItem == nil)
      #expect(forwardedIndex == 3)
    }
  }

  @Test
  func `outlineView(_:acceptDrop:item:childIndex:) with nested item drop, should forward the mapped item and index`() throws {
    try withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let root = OutlineViewDiffableTestNode(id: 0, children: [.init(id: 1), .init(id: 2)])
      let draggingInfo = OutlineViewDiffableDraggingInfoStub(draggingSourceOperationMask: .copy)
      nonisolated(unsafe) var forwardedItem: OutlineViewDiffableTestNode?
      nonisolated(unsafe) var forwardedIndex: Int?
      nonisolated(unsafe) var forwardedOutlineView: NSOutlineView?

      harness.dataSource.apply(harness.makeSnapshot([root]), animatingDifferences: false)
      harness.expandAllItems()

      harness.dataSource.acceptDrop = { outlineView, info, item, index in
        forwardedOutlineView = outlineView
        forwardedItem = item
        forwardedIndex = index
        #expect(info === draggingInfo)
        return true
      }

      let nestedItem = try #require(harness.outlineView.item(atRow: 0))
      let result = harness.dataSource.outlineView(
        harness.outlineView,
        acceptDrop: draggingInfo,
        item: nestedItem,
        childIndex: 1,
      )

      #expect(result)
      #expect(forwardedOutlineView === harness.outlineView)
      #expect(forwardedItem == root)
      #expect(forwardedIndex == 1)
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with exhaustive three node forests, should preserve public behavior`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let forests = outlineViewDiffableTestForests(of: [0, 1, 2])
      var sawInsert = false
      var sawMove = false
      var sawRemove = false

      #expect(forests.count == 46)

      for fromNodes in forests {
        for toNodes in forests {
          nonisolated(unsafe) var completionArguments = [Bool]()

          harness.dataSource.apply(harness.makeSnapshot(fromNodes), animatingDifferences: false)
          harness.expandAllItems()
          harness.resetOperationLog()

          harness.dataSource.apply(harness.makeSnapshot(toNodes), animatingDifferences: true) { didApply in
            completionArguments.append(didApply)
          }

          var issues = harness.inconsistencies(with: toNodes)
          if completionArguments != [fromNodes != toNodes] {
            issues.append("completion was called with \(completionArguments)")
          }
          if harness.outlineView.reloadDataCallCount > 0 {
            issues.append("fell back to reloading")
          }

          harness.expandAllItems()
          if harness.visibleIDs() != toNodes.preorderIDs {
            issues.append("fully expanded: \(harness.visibleIDs())")
          }

          if !issues.isEmpty {
            Issue.record(
              """
              from: \(fromNodes.forestDescription)
              to: \(toNodes.forestDescription)
              \(issues.joined(separator: "\n"))
              """
            )
            return
          }

          expectPublicTree(toNodes, in: harness)

          sawInsert = sawInsert || harness.outlineView.insertCallCount > 0
          sawMove = sawMove || harness.outlineView.moveCallCount > 0
          sawRemove = sawRemove || harness.outlineView.removeCallCount > 0
        }
      }

      #expect(sawInsert)
      #expect(sawMove)
      #expect(sawRemove)
    }
  }

  @Test(arguments: [1, 2, 3, 4] as [UInt64], [false, true])
  func `apply(_:animatingDifferences:completion:) with random forests and expansion states, should keep the outline view consistent`(
    seed: UInt64,
    isInWindow: Bool,
  ) async {
    let harness = OutlineViewDiffableTestHarness(isInWindow: isInWindow)
    var generator = OutlineViewDiffableTestRandomNumberGenerator(seed: seed)
    var fromNodes = [OutlineViewDiffableTestNode]()

    for step in 0..<300 {
      let items = (0..<harness.outlineView.numberOfRows).map { harness.outlineView.item(atRow: $0) }
      for item in items where Bool.random(using: &generator) {
        if harness.outlineView.isItemExpanded(item) {
          harness.outlineView.collapseItem(item)
        } else {
          harness.outlineView.expandItem(item)
        }
      }

      let expandedIDs = harness.expandedIDs()
      let toNodes = [OutlineViewDiffableTestNode].random(idCount: 10, using: &generator)
      let isAnimated = step % 8 != 0
      harness.resetOperationLog()

      harness.dataSource.apply(harness.makeSnapshot(toNodes), animatingDifferences: isAnimated)

      var issues = harness.inconsistencies(with: toNodes)
      if isAnimated, harness.outlineView.reloadDataCallCount > 0 {
        issues.append("fell back to reloading")
      }
      if harness.outlineView.reloadItemInsideUpdatesCallCount > 0 {
        issues.append("reloaded an item in the middle of an update")
      }

      if step % 10 == 0 {
        // Lets deferred reloads through every now and then.
        await Task.yield()
        harness.expandAllItems()
        if harness.visibleIDs() != toNodes.preorderIDs {
          issues.append("fully expanded: \(harness.visibleIDs())")
        }
      }

      if !issues.isEmpty {
        Issue.record(
          """
          step: \(step)
          from: \(fromNodes.forestDescription)
          to: \(toNodes.forestDescription)
          expanded: \(expandedIDs.sorted())
          \(issues.joined(separator: "\n"))
          """
        )
        return
      }

      fromNodes = toNodes
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with changed values in a window, should reload their rows once the animations end`(
  ) async {
    let harness = OutlineViewDiffableTestHarness(isInWindow: true)

    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0), .init(id: 1), .init(id: 2)]),
      animatingDifferences: false,
    )
    #expect(harness.visibleIDs() == [0, 1, 2])
    harness.resetOperationLog()

    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0), .init(id: 2), .init(id: 1, version: 1)]),
      animatingDifferences: true,
    )

    #expect(harness.visibleIDs() == [0, 2, 1])
    #expect(harness.dataSource.itemIdentifier(for: 1)?.version == 1)
    #expect(harness.outlineView.reloadItemCallCount == 0)
    #expect(harness.outlineView.noteHeightOfRowsCallCount == 1)

    #expect(await harness.wait { harness.outlineView.reloadItemCallCount > 0 })
    #expect(harness.outlineView.reloadItemCallCount == 1)
    #expect(harness.outlineView.reloadDataCallCount == 0)
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with changed expandability in a window, should reload the item right away`(
  ) {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness(isInWindow: true)

      harness.dataSource.apply(harness.makeSnapshot([.init(id: 0), .init(id: 1)]), animatingDifferences: false)
      #expect(harness.visibleIDs() == [0, 1])
      harness.resetOperationLog()

      harness.dataSource.apply(
        harness.makeSnapshot([.init(id: 0, children: [.init(id: 2)]), .init(id: 1, version: 1)]),
        animatingDifferences: true,
      )

      #expect(harness.outlineView.reloadItemCallCount == 1)

      harness.outlineView.expandItem(harness.outlineView.item(atRow: 0))

      #expect(harness.visibleIDs() == [0, 2, 1])
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) again before the animations end in a window, should reload every row that changed since`(
  ) async {
    let harness = OutlineViewDiffableTestHarness(isInWindow: true)

    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0), .init(id: 1), .init(id: 2)]),
      animatingDifferences: false,
    )
    #expect(harness.visibleIDs() == [0, 1, 2])
    harness.resetOperationLog()

    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0, version: 1), .init(id: 1), .init(id: 2)]),
      animatingDifferences: true,
    )
    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0, version: 1), .init(id: 1), .init(id: 2, version: 1), .init(id: 3)]),
      animatingDifferences: true,
    )

    #expect(harness.outlineView.reloadItemCallCount == 0)
    #expect(await harness.wait { harness.outlineView.reloadItemCallCount >= 2 })
    // Gives a second, stale reload the chance to show up.
    try? await Task.sleep(for: .milliseconds(500))
    #expect(harness.outlineView.reloadItemCallCount == 2)
  }

  @Test
  func `apply(_:animatingDifferences:completion:) without animation before the animations end in a window, should not reload rows again`(
  ) async {
    let harness = OutlineViewDiffableTestHarness(isInWindow: true)

    harness.dataSource.apply(harness.makeSnapshot([.init(id: 0), .init(id: 1)]), animatingDifferences: false)
    #expect(harness.visibleIDs() == [0, 1])

    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0, version: 1), .init(id: 1)]),
      animatingDifferences: true,
    )
    harness.dataSource.apply(
      harness.makeSnapshot([.init(id: 0, version: 2), .init(id: 1)]),
      animatingDifferences: false,
    )
    harness.resetOperationLog()
    try? await Task.sleep(for: .milliseconds(500))

    #expect(harness.outlineView.reloadItemCallCount == 0)
    #expect(harness.visibleIDs() == [0, 1])
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with moved expanded items, should keep them expanded`() {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let first = OutlineViewDiffableTestNode(id: 0, children: [.init(id: 1)])
      let second = OutlineViewDiffableTestNode(id: 2, children: [.init(id: 3, children: [.init(id: 4)])])

      harness.dataSource.apply(harness.makeSnapshot([first, second, .init(id: 5)]), animatingDifferences: false)
      harness.expandAllItems()
      harness.resetOperationLog()

      harness.dataSource.apply(
        harness.makeSnapshot([
          .init(id: 5),
          .init(id: 2, children: [first, .init(id: 3, children: [.init(id: 4)])]),
        ]),
        animatingDifferences: true,
      )

      #expect(harness.outlineView.reloadDataCallCount == 0)
      #expect(harness.visibleIDs() == [5, 2, 0, 1, 3, 4])
      #expect(harness.expandedIDs() == [0, 2, 3])
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with animated apply right after a reload, should diff against the reloaded snapshot`(
  ) {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let nodes = [OutlineViewDiffableTestNode(id: 0), .init(id: 1), .init(id: 2)]

      // Nothing asks the outline view for its rows in between, so it only loads the first snapshot lazily.
      harness.dataSource.apply(harness.makeSnapshot(nodes), animatingDifferences: false)
      harness.dataSource.apply(harness.makeSnapshot([nodes[2], .init(id: 3), nodes[0]]), animatingDifferences: true)

      #expect(harness.visibleIDs() == [2, 3, 0])
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with animated apply right after a reload of expanded items, should diff against the reloaded snapshot`(
  ) {
    withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      func nodes(version: Int, grandchildren: [Int]) -> [OutlineViewDiffableTestNode] {
        [
          .init(id: 0, children: [.init(id: 1, version: version, children: grandchildren.map { .init(id: $0) })]),
          .init(id: 4, children: [.init(id: 6), .init(id: 7), .init(id: 8)]),
        ]
      }

      harness.dataSource.apply(harness.makeSnapshot(nodes(version: 0, grandchildren: [2, 3])), animatingDifferences: false)
      harness.expandAllItems()
      harness.outlineView.collapseItem(harness.outlineView.item(atRow: 0))

      harness.dataSource.apply(harness.makeSnapshot(nodes(version: 1, grandchildren: [2, 3])), animatingDifferences: false)
      harness.dataSource.apply(
        harness.makeSnapshot([
          .init(id: 4, children: [.init(id: 8), .init(id: 9), .init(id: 6)]),
          .init(id: 0, children: [.init(id: 1, version: 1, children: [.init(id: 3), .init(id: 5), .init(id: 2)])]),
        ]),
        animatingDifferences: true,
      )

      #expect(harness.visibleIDs() == [4, 8, 9, 6, 0])

      harness.expandAllItems()

      #expect(harness.visibleIDs() == [4, 8, 9, 6, 0, 1, 3, 5, 2])
    }
  }

  @Test
  func `apply(_:animatingDifferences:completion:) with curated four node transitions, should cover mixed mutations and reload behavior`(
  ) throws {
    try withOutlineViewDiffableTestLock {
      let harness = OutlineViewDiffableTestHarness()
      let cases: [([OutlineViewDiffableTestNode], [OutlineViewDiffableTestNode])] = [
        (
          [
            .init(id: 0, children: [.init(id: 1)]),
            .init(id: 2),
            .init(id: 3),
          ],
          [
            .init(id: 3, children: [.init(id: 1), .init(id: 2)]),
            .init(id: 0),
          ],
        ),
        (
          [
            .init(id: 0),
            .init(id: 1),
            .init(id: 2),
            .init(id: 3),
          ],
          [
            .init(id: 0),
            .init(id: 3, children: [.init(id: 1), .init(id: 2)]),
          ],
        ),
        (
          [
            .init(id: 0, children: [.init(id: 1)]),
            .init(id: 2, children: [.init(id: 3)]),
          ],
          [
            .init(id: 3),
            .init(id: 0),
            .init(id: 1),
          ],
        ),
        (
          [
            .init(id: 0, children: [.init(id: 1, children: [.init(id: 2)])]),
            .init(id: 3),
          ],
          [
            .init(id: 2),
            .init(id: 0),
            .init(id: 3, children: [.init(id: 1)]),
          ],
        ),
        (
          [
            .init(id: 0, version: 0),
            .init(id: 1, version: 0),
            .init(id: 2, version: 0),
            .init(id: 3, version: 0),
          ],
          [
            .init(id: 3, version: 1),
            .init(id: 0, version: 0),
            .init(id: 2, version: 2),
          ],
        ),
      ]
      nonisolated(unsafe) var sawReloadItem = false

      for (fromNodes, toNodes) in cases {
        nonisolated(unsafe) var completionArguments = [Bool]()

        harness.dataSource.apply(harness.makeSnapshot(fromNodes), animatingDifferences: false)
        harness.expandAllItems()
        harness.resetOperationLog()

        harness.dataSource.apply(harness.makeSnapshot(toNodes), animatingDifferences: true) { didApply in
          completionArguments.append(didApply)
        }
        harness.expandAllItems()

        #expect(completionArguments == [fromNodes != toNodes])
        #expect(harness.visibleIDs() == toNodes.preorderIDs)

        expectPublicTree(toNodes, in: harness)

        for row in 0..<harness.outlineView.numberOfRows {
          let node = try #require(harness.dataSource.itemIdentifier(forRow: row))
          #expect(harness.dataSource.row(for: node) == row)
        }

        sawReloadItem = sawReloadItem || harness.outlineView.reloadItemCallCount > 0
      }

      #expect(sawReloadItem)
    }
  }

  // MARK: Private

  private struct TestNode: Equatable, Hashable, Identifiable, TreeNodeProtocol {
    init(id: Int, children: [Self] = [], version: Int = 0) {
      self.id = id
      self.version = version
      self.children = .init(uniqueElements: children)
    }

    var id: Int
    var children = IdentifiedArrayOf<Self>()
    var version = 0
  }

  private final class TestOutlineView: NSOutlineView {

    // MARK: Internal

    static let rootParentID = -1

    var numberOfChildrenByParentID = [Int: Int]()
    var parentIDByItemID = [Int: Int]()
    var childIndexByItemID = [Int: Int]()
    var insertedOperations = [InsertOperation]()
    var moveOperations = [MoveOperation]()
    var removedOperations = [RemoveOperation]()
    var beginUpdatesCallCount = 0
    var endUpdatesCallCount = 0
    var reloadDataCallCount = 0

    override func beginUpdates() {
      beginUpdatesCallCount += 1
    }

    override func endUpdates() {
      endUpdatesCallCount += 1
    }

    override func numberOfChildren(ofItem item: Any?) -> Int {
      numberOfChildrenByParentID[parentID(for: item)] ?? 0
    }

    override func parent(forItem item: Any?) -> Any? {
      guard
        let itemID = itemID(for: item),
        let parentID = parentIDByItemID[itemID],
        parentID != Self.rootParentID
      else {
        return nil
      }

      return DiffableOutlineItem(TestNode(id: parentID))
    }

    override func childIndex(forItem item: Any) -> Int {
      guard let itemID = itemID(for: item) else { return -1 }
      return childIndexByItemID[itemID] ?? -1
    }

    override func insertItems(
      at indexes: IndexSet,
      inParent parent: Any?,
      withAnimation _: NSTableView.AnimationOptions = [],
    ) {
      insertedOperations.append(
        .init(
          indexes: Array(indexes),
          parentID: parentID(for: parent),
        )
      )
    }

    override func moveItem(at oldIndex: Int, inParent oldParent: Any?, to newIndex: Int, inParent newParent: Any?) {
      moveOperations.append(
        .init(
          fromIndex: oldIndex,
          fromParentID: parentID(for: oldParent),
          toIndex: newIndex,
          toParentID: parentID(for: newParent),
        )
      )
    }

    override func removeItems(
      at indexes: IndexSet,
      inParent parent: Any?,
      withAnimation _: NSTableView.AnimationOptions = [],
    ) {
      removedOperations.append(
        .init(
          indexes: Array(indexes),
          parentID: parentID(for: parent),
        )
      )
    }

    override func reloadData() {
      reloadDataCallCount += 1
    }

    func reset() {
      numberOfChildrenByParentID.removeAll()
      parentIDByItemID.removeAll()
      childIndexByItemID.removeAll()
      insertedOperations.removeAll()
      moveOperations.removeAll()
      removedOperations.removeAll()
      beginUpdatesCallCount = 0
      endUpdatesCallCount = 0
      reloadDataCallCount = 0
    }

    // MARK: Private

    private func itemID(for item: Any?) -> Int? {
      if let item = item as? DiffableOutlineItem<TestNode> {
        return item.id
      }
      if let item = item as? TestNode {
        return item.id
      }
      return nil
    }

    private func parentID(for item: Any?) -> Int {
      itemID(for: item) ?? Self.rootParentID
    }
  }

  private struct InsertOperation: Equatable {
    var indexes: [Int]
    var parentID: Int
  }

  private struct MoveOperation: Equatable {
    var fromIndex: Int
    var fromParentID: Int
    var toIndex: Int
    var toParentID: Int
  }

  private struct RemoveOperation: Equatable {
    var indexes: [Int]
    var parentID: Int
  }

  private func expectPublicTree(
    _ expectedNodes: [OutlineViewDiffableTestNode],
    in harness: OutlineViewDiffableTestHarness,
    item: Any? = nil,
  ) {
    #expect(
      harness.dataSource.outlineView(harness.outlineView, numberOfChildrenOfItem: item)
        == expectedNodes.count
    )

    for (index, expectedNode) in expectedNodes.enumerated() {
      let child = harness.dataSource.outlineView(harness.outlineView, child: index, ofItem: item)
      let row = harness.outlineView.row(forItem: child)
      if row >= 0 {
        #expect(harness.dataSource.itemIdentifier(forRow: row) == expectedNode)
      } else {
        #expect(harness.dataSource.itemIdentifier(for: expectedNode.id) == expectedNode)
      }

      expectPublicTree(expectedNode.children.elements, in: harness, item: child)
    }
  }
}
