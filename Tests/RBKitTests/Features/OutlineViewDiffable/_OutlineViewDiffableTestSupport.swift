import AppKit
import Foundation
import IdentifiedCollections

@testable import RBKit

// MARK: - OutlineViewDiffableTestLock

private enum OutlineViewDiffableTestLock {
  static let value = NSLock()
}

@MainActor
func withOutlineViewDiffableTestLock<Result>(_ body: () throws -> Result) rethrows -> Result {
  OutlineViewDiffableTestLock.value.lock()
  defer { OutlineViewDiffableTestLock.value.unlock() }
  return try body()
}

// MARK: - OutlineViewDiffableTestNode

struct OutlineViewDiffableTestNode: Equatable, Hashable, Identifiable, TreeNodeProtocol {
  init(id: Int, title: String? = nil, version: Int = 0, children: [Self] = []) {
    self.id = id
    self.title = title ?? "Node \(id)"
    self.version = version
    self.children = .init(uniqueElements: children)
  }

  var id: Int
  var title: String
  var version: Int
  var children = IdentifiedArrayOf<Self>()
}

// MARK: - OutlineViewDiffableTestHarness

@MainActor
final class OutlineViewDiffableTestHarness {

  // MARK: Lifecycle

  init(isInWindow: Bool = false) {
    _ = NSApplication.shared

    outlineView = SpyOutlineView()
    let column = NSTableColumn(identifier: .init("column"))
    outlineView.addTableColumn(column)
    outlineView.outlineTableColumn = column

    if isInWindow {
      let window = NSWindow(
        contentRect: .init(x: 0, y: 0, width: 300, height: 600),
        styleMask: .borderless,
        backing: .buffered,
        defer: true,
      )
      window.isReleasedWhenClosed = false
      let scrollView = NSScrollView()
      scrollView.documentView = outlineView
      window.contentView = scrollView
      self.window = window
    }

    dataSource = OutlineViewDiffableDataSource(outlineView: outlineView)
    dataSource.isExpandable = { !$0.children.isEmpty }
  }

  // MARK: Internal

  final class SpyOutlineView: NSOutlineView {

    // MARK: Internal

    var beginUpdatesCallCount = 0
    var endUpdatesCallCount = 0
    var insertCallCount = 0
    var moveCallCount = 0
    var reloadDataCallCount = 0
    var reloadItemCallCount = 0
    var reloadItemInsideUpdatesCallCount = 0
    var removeCallCount = 0
    var noteHeightOfRowsCallCount = 0

    override func beginUpdates() {
      beginUpdatesCallCount += 1
      isUpdating = true
      super.beginUpdates()
    }

    override func endUpdates() {
      endUpdatesCallCount += 1
      super.endUpdates()
      isUpdating = false
    }

    override func insertItems(
      at indexes: IndexSet,
      inParent parent: Any?,
      withAnimation animationOptions: NSTableView.AnimationOptions = [],
    ) {
      insertCallCount += 1
      super.insertItems(at: indexes, inParent: parent, withAnimation: animationOptions)
    }

    override func moveItem(at oldIndex: Int, inParent oldParent: Any?, to newIndex: Int, inParent newParent: Any?) {
      moveCallCount += 1
      super.moveItem(at: oldIndex, inParent: oldParent, to: newIndex, inParent: newParent)
    }

    override func removeItems(
      at indexes: IndexSet,
      inParent parent: Any?,
      withAnimation animationOptions: NSTableView.AnimationOptions = [],
    ) {
      removeCallCount += 1
      super.removeItems(at: indexes, inParent: parent, withAnimation: animationOptions)
    }

    override func reloadData() {
      reloadDataCallCount += 1
      super.reloadData()
    }

    override func reloadItem(_ item: Any?) {
      reloadItemCallCount += 1
      if isUpdating {
        reloadItemInsideUpdatesCallCount += 1
      }
      super.reloadItem(item)
    }

    override func noteHeightOfRows(withIndexesChanged indexSet: IndexSet) {
      noteHeightOfRowsCallCount += 1
      super.noteHeightOfRows(withIndexesChanged: indexSet)
    }

    // MARK: Private

    private var isUpdating = false
  }

  let outlineView: SpyOutlineView
  let dataSource: OutlineViewDiffableDataSource<OutlineViewDiffableTestNode>
  private(set) var window: NSWindow?

  /// Animation completion handlers are delivered on the main queue, which only gets to run once the test suspends.
  func wait(until condition: () -> Bool) async -> Bool {
    for _ in 0..<200 where !condition() {
      try? await Task.sleep(for: .milliseconds(10))
    }
    return condition()
  }

  func makeSnapshot(_ items: [OutlineViewDiffableTestNode]) -> OutlineViewDiffableSnapshot<OutlineViewDiffableTestNode> {
    var snapshot = OutlineViewDiffableSnapshot<OutlineViewDiffableTestNode>()
    snapshot.append(items: items)
    return snapshot
  }

  func expandAllItems() {
    var row = 0
    while row < outlineView.numberOfRows {
      let item = outlineView.item(atRow: row)
      if dataSource.outlineView(outlineView, numberOfChildrenOfItem: item) > 0 {
        outlineView.expandItem(item)
      }
      row += 1
    }
  }

  func resetOperationLog() {
    outlineView.beginUpdatesCallCount = 0
    outlineView.endUpdatesCallCount = 0
    outlineView.insertCallCount = 0
    outlineView.moveCallCount = 0
    outlineView.reloadDataCallCount = 0
    outlineView.reloadItemCallCount = 0
    outlineView.reloadItemInsideUpdatesCallCount = 0
    outlineView.removeCallCount = 0
    outlineView.noteHeightOfRowsCallCount = 0
  }

  func visibleIDs() -> [Int] {
    (0..<outlineView.numberOfRows).compactMap { dataSource.itemIdentifier(forRow: $0)?.id }
  }

  func expandedIDs() -> Set<Int> {
    Set(
      (0..<outlineView.numberOfRows).compactMap { row in
        outlineView.isItemExpanded(outlineView.item(atRow: row)) ? dataSource.itemIdentifier(forRow: row)?.id : nil
      }
    )
  }

  func expectedVisibleIDs(for nodes: [OutlineViewDiffableTestNode]) -> [Int] {
    nodes.flatMap { node in
      let isExpanded = outlineView.isItemExpanded(DiffableOutlineItem(node))
      return [node.id] + (isExpanded ? expectedVisibleIDs(for: node.children.elements) : [])
    }
  }

  func inconsistencies(with nodes: [OutlineViewDiffableTestNode]) -> [String] {
    var inconsistencies = [String]()

    let visibleIDs = visibleIDs()
    if visibleIDs.count != outlineView.numberOfRows {
      inconsistencies.append("\(outlineView.numberOfRows - visibleIDs.count) rows have no item identifier")
    }
    if visibleIDs != expectedVisibleIDs(for: nodes) {
      inconsistencies.append("visible: \(visibleIDs), expected: \(expectedVisibleIDs(for: nodes))")
    }

    func visit(_ nodes: [OutlineViewDiffableTestNode], parent: OutlineViewDiffableTestNode?) {
      let parentItem = parent.map { DiffableOutlineItem($0) }
      let childCount = outlineView.numberOfChildren(ofItem: parentItem)
      if childCount != nodes.count {
        inconsistencies.append("\(parent.map { "\($0.id)" } ?? "root") has \(childCount) children, expected \(nodes.count)")
        return
      }

      for (index, node) in nodes.enumerated() {
        let item = DiffableOutlineItem(node)
        let child = outlineView.child(index, ofItem: parentItem) as? DiffableOutlineItem<OutlineViewDiffableTestNode>
        if child?.id != node.id {
          inconsistencies.append("child \(index) of \(parent.map { "\($0.id)" } ?? "root") is \(String(describing: child?.id))")
        }
        if outlineView.isExpandable(item) != !node.children.isEmpty {
          inconsistencies.append("\(node.id) has the wrong expandability")
        }
        if dataSource.itemIdentifier(for: node.id) != node {
          inconsistencies.append("\(node.id) has a stale item identifier")
        }
        if outlineView.isItemExpanded(item) {
          visit(node.children.elements, parent: node)
        }
      }
    }

    visit(nodes, parent: nil)
    return inconsistencies
  }

}

// MARK: - OutlineViewDiffableDraggingInfoStub

@MainActor
final class OutlineViewDiffableDraggingInfoStub: NSObject, NSDraggingInfo {

  // MARK: Lifecycle

  init(draggingSourceOperationMask: NSDragOperation = []) {
    self.draggingSourceOperationMask = draggingSourceOperationMask
  }

  // MARK: Internal

  var animatesToDestination = false
  let draggedImageLocation = NSPoint.zero
  let draggingDestinationWindow: NSWindow? = nil
  let draggedImage: NSImage? = nil
  let draggingLocation = NSPoint.zero
  let draggingPasteboard = NSPasteboard(name: .drag)
  var draggingFormation = NSDraggingFormation.default
  let draggingSequenceNumber = 0
  var draggingSource: Any?
  var draggingSourceOperationMask: NSDragOperation
  var numberOfValidItemsForDrop = 0
  let springLoadingHighlight = NSSpringLoadingHighlight.none

  func slideDraggedImage(to _: NSPoint) { }

  override func namesOfPromisedFilesDropped(atDestination _: URL) -> [String]? {
    nil
  }

  func enumerateDraggingItems(
    options _: NSDraggingItemEnumerationOptions = [],
    for _: NSView?,
    classes _: [AnyClass],
    searchOptions _: [NSPasteboard.ReadingOptionKey: Any] = [:],
    using _: (NSDraggingItem, Int, UnsafeMutablePointer<ObjCBool>) -> Void,
  ) { }

  func resetSpringLoading() { }
}

// MARK: - Forests

func outlineViewDiffableTestForests(of ids: Set<Int>) -> [[OutlineViewDiffableTestNode]] {
  var forests: [[OutlineViewDiffableTestNode]] = [[]]

  for rootID in ids.sorted() {
    let remainingIDs = ids.subtracting([rootID])
    for children in outlineViewDiffableTestForests(of: remainingIDs) {
      let siblingIDs = remainingIDs.subtracting(children.preorderIDs)
      for siblings in outlineViewDiffableTestForests(of: siblingIDs) {
        forests.append([.init(id: rootID, children: children)] + siblings)
      }
    }
  }

  return forests
}

extension [OutlineViewDiffableTestNode] {
  var preorderIDs: [Int] {
    flatMap { [$0.id] + $0.children.elements.preorderIDs }
  }

  var forestDescription: String {
    func description(_ nodes: [OutlineViewDiffableTestNode], separator: String) -> String {
      nodes.map { node in
        node.children.isEmpty ? "\(node.id)" : "\(node.id)(\(description(node.children.elements, separator: ",")))"
      }
      .joined(separator: separator)
    }

    return isEmpty ? "[]" : description(self, separator: "|")
  }

  static func random(
    idCount: Int,
    using generator: inout some RandomNumberGenerator,
  ) -> Self {
    var childIDsByID = [Int: [Int]]()
    var rootIDs = [Int]()

    for id in (0..<idCount).shuffled(using: &generator) where Bool.random(using: &generator) {
      let parentID = Int.random(in: 0...2, using: &generator) == 0
        ? nil
        : childIDsByID.keys.sorted().randomElement(using: &generator)
      if let parentID {
        let index = Int.random(in: 0...childIDsByID[parentID, default: []].count, using: &generator)
        childIDsByID[parentID, default: []].insert(id, at: index)
      } else {
        rootIDs.insert(id, at: Int.random(in: 0...rootIDs.count, using: &generator))
      }
      childIDsByID[id] = []
    }

    func makeNode(_ id: Int) -> OutlineViewDiffableTestNode {
      .init(
        id: id,
        version: Int.random(in: 0...1, using: &generator),
        children: childIDsByID[id, default: []].map(makeNode),
      )
    }

    return rootIDs.map(makeNode)
  }
}

// MARK: - OutlineViewDiffableTestRandomNumberGenerator

/// SplitMix64, so that randomized tests are reproducible.
struct OutlineViewDiffableTestRandomNumberGenerator: RandomNumberGenerator {
  init(seed: UInt64) {
    state = seed
  }

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var result = state
    result = (result ^ (result >> 30)) &* 0xBF58_476D_1CE4_E5B9
    result = (result ^ (result >> 27)) &* 0x94D0_49BB_1331_11EB
    return result ^ (result >> 31)
  }

  private var state: UInt64
}
