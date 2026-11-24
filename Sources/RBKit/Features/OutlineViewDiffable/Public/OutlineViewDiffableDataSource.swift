import AppKit

private let log = RBLogger("OutlineViewDiffable")

// MARK: - OutlineViewDiffableDataSource

@MainActor
public final class OutlineViewDiffableDataSource<Item: TreeNodeProtocol & Hashable & Sendable>: NSObject,
  NSOutlineViewDataSource
{

  // MARK: Lifecycle

  public init(outlineView: NSOutlineView) {
    self.outlineView = outlineView
    super.init()
    outlineView.dataSource = self
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(outlineViewItemDidExpand),
      name: NSOutlineView.itemDidExpandNotification,
      object: outlineView,
    )
  }

  // MARK: Public

  /// Whether an item can be expanded. When unset, items that have children are expandable.
  public var isExpandable: ((Item) -> Bool)?
  public var validateDrop: ((NSOutlineView, any NSDraggingInfo, Item?, Int) -> NSDragOperation)?
  public var acceptDrop: ((NSOutlineView, any NSDraggingInfo, Item?, Int) -> Bool)?

  public var fallbackItemRowHeight: CGFloat {
    1
  }

  public func apply(
    _ snapshot: OutlineViewDiffableSnapshot<Item>,
    animatingDifferences: Bool,
    completion: ((_ didApply: Bool) -> Void)? = nil,
  ) {
    guard let outlineView else {
      currentSnapshot = snapshot
      completion?(true)
      return
    }

    if currentSnapshot.hasSameValues(as: snapshot) {
      currentSnapshot = snapshot
      completion?(false)
      return
    }

    // The outline view forgets the expansion and selection of items it reloads, of items that are re-created under a
    // new parent, and of items that move into a collapsed parent.
    let viewState = viewState(of: outlineView)

    guard animatingDifferences, let operations = currentSnapshot.operations(to: snapshot) else {
      currentSnapshot = snapshot
      deferredReloadBaseline = nil
      outlineView.reloadData()
      restore(viewState, on: outlineView)
      completion?(true)
      return
    }

    for row in 0..<outlineView.numberOfRows {
      _ = outlineView.item(atRow: row)
    }

    let oldSnapshot = currentSnapshot
    currentSnapshot = snapshot

    guard outlineView.window != nil else {
      outlineView.beginUpdates()
      perform(operations, from: oldSnapshot, on: outlineView)
      outlineView.endUpdates()
      reloadChangedItems(from: oldSnapshot, on: outlineView, deferringDisplayedItems: false)
      restore(viewState, on: outlineView)
      completion?(true)
      return
    }

    let baseline = deferredReloadBaseline ?? oldSnapshot
    deferredReloadBaseline = baseline
    deferredReloadID += 1
    let reloadID = deferredReloadID

    outlineView.beginUpdates()
    perform(operations, from: oldSnapshot, on: outlineView)

    // without this in the completion handler, cell sizes are fucked up
    let animationContext = NSAnimationContext.current
    let previousCompletionHandler = animationContext.completionHandler
    animationContext.completionHandler = { [weak self] in
      previousCompletionHandler?()
      MainActor.assumeIsolated {
        guard let self, reloadID == self.deferredReloadID, let baseline = self.deferredReloadBaseline else { return }
        self.deferredReloadBaseline = nil
        guard let outlineView = self.outlineView else { return }
        self.reloadChangedItems(from: baseline, on: outlineView, deferringDisplayedItems: false)
      }
    }

    outlineView.endUpdates()
    reloadChangedItems(from: oldSnapshot, on: outlineView, deferringDisplayedItems: true)
    restore(viewState, on: outlineView)

    completion?(true)
  }

  public func itemIdentifier(for id: Item.ID) -> Item? {
    currentSnapshot.item(id: id)?.value
  }

  public func itemIdentifier(forRow row: Int) -> Item? {
    guard
      let outlineView,
      row >= 0
    else {
      return nil
    }

    return currentSnapshot.outlineItem(for: outlineView.item(atRow: row))?.value
  }

  /// Returns the current value of an item the outline view passed to its delegate or data source.
  public func itemIdentifier(forItem item: Any?) -> Item? {
    currentSnapshot.outlineItem(for: item)?.value
  }

  public func row(for itemIdentifier: Item) -> Int? {
    guard
      let outlineView,
      let item = currentSnapshot.item(id: itemIdentifier.id)
    else {
      return nil
    }

    let row = outlineView.row(forItem: item)
    if row < 0 { return nil }
    return row
  }

  public func isFallbackItem(_ item: Any?) -> Bool {
    (item as AnyObject?) === fallbackItem
  }

  public func outlineView(_: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    let children = currentSnapshot.children(of: item)
    if children.indices.contains(index) {
      return children[index]
    }

    let parent = String(describing: currentSnapshot.outlineItem(for: item))
    log.os.error(
      """
      OUTLINE DIFF MISSING CHILD
      REASON: The outline view requested a child that isn't in the current snapshot.
      INDEX: \(index, privacy: .public)
      PARENT: \(parent)
      """
    )
    return fallbackItem
  }

  public func outlineView(_: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    currentSnapshot.children(of: item).count
  }

  public func outlineView(_: NSOutlineView, isItemExpandable item: Any) -> Bool {
    currentSnapshot.outlineItem(for: item).map(isExpandable) ?? false
  }

  public func outlineView(
    _ outlineView: NSOutlineView,
    validateDrop info: any NSDraggingInfo,
    proposedItem item: Any?,
    proposedChildIndex index: Int,
  ) -> NSDragOperation {
    validateDrop?(outlineView, info, currentSnapshot.outlineItem(for: item)?.value, index) ?? []
  }

  public func outlineView(
    _ outlineView: NSOutlineView,
    acceptDrop info: any NSDraggingInfo,
    item: Any?,
    childIndex index: Int,
  ) -> Bool {
    acceptDrop?(outlineView, info, currentSnapshot.outlineItem(for: item)?.value, index) ?? false
  }

  // MARK: Internal

  let insertionAnimationOptions: NSTableView.AnimationOptions = [.effectFade, .slideDown]
  let removalAnimationOptions: NSTableView.AnimationOptions = [.effectFade, .slideDown]

  // MARK: Private

  private final class FallbackItem: NSObject { }

  private struct ViewState {
    var expandedIDs = [Item.ID]()
    var selectedIDs = [Item.ID]()
  }

  private weak var outlineView: NSOutlineView?
  private var currentSnapshot = OutlineViewDiffableSnapshot<Item>()
  private let fallbackItem = FallbackItem()

  private var deferredReloadBaseline: OutlineViewDiffableSnapshot<Item>?
  private var deferredReloadID = 0

  /// Items that were expanded before they ended up inside a collapsed parent.
  private var pendingExpandedIDs = Set<Item.ID>()

  @objc
  private func outlineViewItemDidExpand(_ notification: Notification) {
    if pendingExpandedIDs.isEmpty { return }
    guard let outlineView, let parent = currentSnapshot.outlineItem(for: notification.userInfo?["NSObject"]) else { return }

    for child in parent.children where pendingExpandedIDs.remove(child.id) != nil {
      if isExpandable(child) {
        outlineView.expandItem(child)
      }
    }
  }

  private func viewState(of outlineView: NSOutlineView) -> ViewState {
    var viewState = ViewState()
    let selectedRows = outlineView.selectedRowIndexes
    for row in 0..<outlineView.numberOfRows {
      let item = outlineView.item(atRow: row)
      guard let id = (item as? DiffableOutlineItem<Item>)?.id else { continue }
      if outlineView.isItemExpanded(item) {
        viewState.expandedIDs.append(id)
      }
      if selectedRows.contains(row) {
        viewState.selectedIDs.append(id)
      }
    }
    return viewState
  }

  private func restore(_ viewState: ViewState, on outlineView: NSOutlineView) {
    // The outline view can't expand an item inside a collapsed parent, so those wait for the parent to expand.
    var stillPendingIDs = Set<Item.ID>()
    for id in viewState.expandedIDs + pendingExpandedIDs.filter({ !viewState.expandedIDs.contains($0) }) {
      guard let item = currentSnapshot.item(id: id), isExpandable(item) else { continue }
      if outlineView.isItemExpanded(item) { continue }
      outlineView.expandItem(item)
      if !outlineView.isItemExpanded(item) {
        stillPendingIDs.insert(id)
      }
    }
    pendingExpandedIDs = stillPendingIDs

    let selectedRows = IndexSet(
      viewState.selectedIDs.compactMap { id in
        currentSnapshot.item(id: id).map(outlineView.row(forItem:)).flatMap { $0 >= 0 ? $0 : nil }
      }
    )
    if selectedRows != outlineView.selectedRowIndexes {
      outlineView.selectRowIndexes(selectedRows, byExtendingSelection: false)
    }
  }

  private func isExpandable(_ item: DiffableOutlineItem<Item>) -> Bool {
    isExpandable?(item.value) ?? !item.children.isEmpty
  }

  private func perform(
    _ operations: [OutlineViewDiffableOperation<Item.ID>],
    from oldSnapshot: OutlineViewDiffableSnapshot<Item>,
    on outlineView: NSOutlineView,
  ) {
    func item(id: Item.ID?) -> DiffableOutlineItem<Item>? {
      id.flatMap { currentSnapshot.item(id: $0) ?? oldSnapshot.item(id: $0) }
    }

    for operation in operations {
      switch operation {
      case .insert(let index, let parentID):
        outlineView.insertItems(at: [index], inParent: item(id: parentID), withAnimation: insertionAnimationOptions)

      case .remove(let index, let parentID):
        outlineView.removeItems(at: [index], inParent: item(id: parentID), withAnimation: removalAnimationOptions)

      case .move(let fromIndex, let fromParentID, let toIndex, let toParentID):
        outlineView.moveItem(at: fromIndex, inParent: item(id: fromParentID), to: toIndex, inParent: item(id: toParentID))
      }
    }
  }

  private func reloadChangedItems(
    from oldSnapshot: OutlineViewDiffableSnapshot<Item>,
    on outlineView: NSOutlineView,
    deferringDisplayedItems: Bool,
  ) {
    var changedRows = IndexSet()

    for parentID in currentSnapshot.orderedParentIDs {
      for item in currentSnapshot.children(parentID: parentID) {
        guard let oldItem = oldSnapshot.item(id: item.id) else { continue }
        let isExpandabilityChanged = isExpandable(oldItem) != isExpandable(item)
        if oldItem.value == item.value, !isExpandabilityChanged { continue }

        let row = outlineView.row(forItem: item)
        if row >= 0 {
          changedRows.insert(row)
          if deferringDisplayedItems, !isExpandabilityChanged { continue }
        }

        outlineView.reloadItem(item)
      }
    }

    outlineView.noteHeightOfRows(withIndexesChanged: changedRows)
  }
}
