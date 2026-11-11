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

  init() {
    _ = NSApplication.shared

    outlineView = SpyOutlineView()
    let column = NSTableColumn(identifier: .init("column"))
    outlineView.addTableColumn(column)
    outlineView.outlineTableColumn = column

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
    var reloadItemOutsideUpdatesCallCount = 0
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

    override func reloadItem(_ _: Any?) {
      reloadItemCallCount += 1
      if !isUpdating {
        reloadItemOutsideUpdatesCallCount += 1
      }
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

  func makeSnapshot(_ items: [OutlineViewDiffableTestNode]) -> OutlineViewDiffableSnapshot<OutlineViewDiffableTestNode> {
    var snapshot = OutlineViewDiffableSnapshot<OutlineViewDiffableTestNode>()
    snapshot.append(items: items)
    return snapshot
  }

  func expandAllItems() {
    settle()
    var row = 0
    while row < outlineView.numberOfRows {
      let item = outlineView.item(atRow: row)
      if dataSource.outlineView(outlineView, numberOfChildrenOfItem: item) > 0 {
        outlineView.expandItem(item)
        settle()
      }
      row += 1
    }
    settle()
  }

  func resetOperationLog() {
    outlineView.beginUpdatesCallCount = 0
    outlineView.endUpdatesCallCount = 0
    outlineView.insertCallCount = 0
    outlineView.moveCallCount = 0
    outlineView.reloadDataCallCount = 0
    outlineView.reloadItemCallCount = 0
    outlineView.reloadItemOutsideUpdatesCallCount = 0
    outlineView.removeCallCount = 0
    outlineView.noteHeightOfRowsCallCount = 0
  }

  func visibleIDs() -> [Int] {
    (0..<outlineView.numberOfRows).compactMap { dataSource.itemIdentifier(forRow: $0)?.id }
  }

  func settle() {
    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.001))
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
