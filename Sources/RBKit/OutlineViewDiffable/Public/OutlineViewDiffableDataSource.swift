import AppKit

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
  }

  // MARK: Public

  public var isExpandable: ((Item) -> Bool)?
  public var validateDrop: ((NSOutlineView, any NSDraggingInfo, Item?, Int) -> NSDragOperation)?
  public var acceptDrop: ((NSOutlineView, any NSDraggingInfo, Item?, Int) -> Bool)?

  public var fallbackItemRowHeight: CGFloat {
    1
  }

  // New algo:
  // =========
  // We will need comparisons of old vs. new of:
  // - Set<ID>
  // - [ID: (parent: ID?, index: Int, descendantsByID: Set<ID>, isLeaf)]
  // - Divide the update to 3 phases of removals, insertions, and moves.
  // - We do one one big Begin/End-Grouping, then 3 more pairs around each of the phases.
  // - As we enter/exit phases, we set the phase on the data source.
  // - Inside data source methods, depending on the phase we know which snapshot to access - the old or the new:
  //  - Removals - old snapshot.
  //  - insertions - new snapshot.
  //  - Moves: we try to item from the old snapshot first (move from), and fallback to the new snapshot (move to).
  //  - Reloads: new snapshot.
  // - In the diff, for removals and insertions, we first get all non-leaf items and their descendants. We then skip operations for descendants because they're included with the parents.
  // - Moves are the trickiest:
  //  - We first move parents
  // - For the remaining items that didn't change between snapshot, we do deep equality check, and if different, reload.
  //
  // Open questions:
  // - New parents insertions - including children already? Even moved children from old parents?
  // - What about child moves between different parents?
  //
  // var updatePhase = UpdatePhase.reload
  // public func _outlineView(_: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
  // switch updatePhase {
  // case .reload, .insertions:
  // if let item = currentSnapshot.outlineItem(for: item) {
  // item[index]
  // } else {
  // currentSnapshot[index]
  // }
  //
  // case .removals:
  // if let item = fallbackSnapshot!.outlineItem(for: item) {
  // item[index]
  // } else {
  // fallbackSnapshot![index]
  // }
  //
  // case .moves:
  // fatalError("unimplemented")
  // }
  // }
  //

  public func apply(
    _ snapshot: OutlineViewDiffableSnapshot<Item>,
    animatingDifferences: Bool,
    completion: ((_ didApply: Bool) -> Void)? = nil,
  ) {
    let oldSnapshot = currentSnapshot
    let newSnapshot = snapshot

    guard let outlineView else {
      currentSnapshot = newSnapshot
      fallbackSnapshot = nil
      completion?(true)
      return
    }

    if oldSnapshot.hasSameValues(as: newSnapshot) {
      currentSnapshot = newSnapshot
      fallbackSnapshot = nil
      completion?(false)
      return
    }

    func applyImmediately() {
      currentSnapshot = newSnapshot
      fallbackSnapshot = nil
      outlineView.reloadData()
      completion?(true)
    }

    func applyWithAnimation() {
      let oldIDs = oldSnapshot.ids
      let newIDs = newSnapshot.ids
      let retainedIDs = oldIDs.intersection(newIDs)
      let removedIDs = oldIDs.subtracting(newIDs)
      let insertedIDs = newIDs.subtracting(oldIDs)
      let oldRetainedChildIDsByParent = Dictionary(
        uniqueKeysWithValues: oldSnapshot.orderedParentIDs.map { parentID in
          (
            parentID,
            oldSnapshot.children(parentID: parentID)
              .filter { retainedIDs.contains($0.id) }
              .map(\.id),
          )
        }
      )
      let newRetainedChildIDsByParent = Dictionary(
        uniqueKeysWithValues: newSnapshot.orderedParentIDs.map { parentID in
          (
            parentID,
            newSnapshot.children(parentID: parentID)
              .filter { retainedIDs.contains($0.id) }
              .map(\.id),
          )
        }
      )
      var currentChildIDsByParent = Dictionary(
        uniqueKeysWithValues: oldSnapshot.orderedParentIDs.map { parentID in
          (parentID, oldSnapshot.children(parentID: parentID).map(\.id))
        }
      )
      var currentParentIDByID = Dictionary(
        uniqueKeysWithValues: oldSnapshot.ids.map { id in
          (id, oldSnapshot.parentID(id: id))
        }
      )
      var movedIDs = Set<Item.ID>()
      var didBeginUpdates = false

      func applyImmediatelyAfterInvalidAnimatedUpdate() {
        if didBeginUpdates {
          outlineView.endUpdates()
          NSAnimationContext.endGrouping()
        }
        applyImmediately()
      }

      fallbackSnapshot = oldSnapshot
      currentSnapshot = newSnapshot

      outlineView.beginUpdates()
      didBeginUpdates = true

      func applyInsertions(
        shouldInsert: (_ targetIndex: Int, _ newChildren: [OutlineItem<Item>], _ newItem: OutlineItem<Item>) -> Bool,
        insertingBeforeRetainedSiblings: Bool,
      ) -> Bool {
        for parentID in newSnapshot.orderedParentIDs {
          let newParent = parentID.flatMap { oldSnapshot.item(id: $0) ?? newSnapshot.item(id: $0) }
          let newChildren = newSnapshot.children(parentID: parentID)
          let targetIndexesByID = Dictionary(
            uniqueKeysWithValues: newChildren.enumerated().map { index, item in
              (item.id, index)
            }
          )

          for (targetIndex, newItem) in newChildren.enumerated()
            where insertedIDs.contains(newItem.id) && shouldInsert(targetIndex, newChildren, newItem)
          {
            let currentInsertIndex: Int =
              if insertingBeforeRetainedSiblings {
                newChildren[..<targetIndex].reduce(into: 0) { result, sibling in
                  if currentChildIDsByParent[parentID, default: []].contains(sibling.id) {
                    result += 1
                  }
                }
              } else {
                currentChildIDsByParent[parentID, default: []]
                  .firstIndex { currentChildID in
                    guard let currentTargetIndex = targetIndexesByID[currentChildID] else {
                      return false
                    }

                    return currentTargetIndex > targetIndex
                  }
                  ?? currentChildIDsByParent[parentID, default: []].count
              }
            let currentChildCount = outlineView.numberOfChildren(ofItem: newParent)
            // The snapshot wants to insert beyond the current sibling count, so the animated plan is no longer valid.
            if currentInsertIndex > currentChildCount {
              logInvalidInsert(
                newItem: newItem,
                toIndex: currentInsertIndex,
                currentChildCount: currentChildCount,
                parentID: parentID,
              )
              applyImmediatelyAfterInvalidAnimatedUpdate()
              return false
            }

            outlineView.insertItems(
              at: IndexSet(integer: currentInsertIndex),
              inParent: newParent,
              withAnimation: insertionAnimationOptions,
            )
            currentChildIDsByParent[parentID, default: []].insert(newItem.id, at: currentInsertIndex)
            currentParentIDByID[newItem.id] = parentID
          }
        }

        return true
      }

      if
        !applyInsertions(
          shouldInsert: { targetIndex, newChildren, newItem in
            !newItem.children.isEmpty || newChildren.dropFirst(targetIndex + 1).contains {
              retainedIDs.contains($0.id)
            }
          },
          insertingBeforeRetainedSiblings: true,
        )
      {
        return
      }

      for parentID in newSnapshot.orderedParentIDs.reversed() {
        let newParent = parentID.flatMap { oldSnapshot.item(id: $0) ?? newSnapshot.item(id: $0) }
        let newChildren = newSnapshot.children(parentID: parentID)
        let targetIndexesByID = Dictionary(
          uniqueKeysWithValues: newChildren.enumerated().map { index, item in
            (item.id, index)
          }
        )

        for (targetIndex, newItem) in newChildren.enumerated() where retainedIDs.contains(newItem.id) {
          guard let oldItem = oldSnapshot.item(id: newItem.id) else { continue }

          let oldParentID = oldSnapshot.parentID(id: newItem.id)
          let oldRetainedIndex = oldRetainedChildIDsByParent[oldParentID]?.firstIndex(of: newItem.id)
          let newRetainedIndex = newRetainedChildIDsByParent[parentID]?.firstIndex(of: newItem.id)

          // Insertions and removals can shift absolute indices without changing the
          // retained siblings' relative order, in which case no move is needed.
          if oldParentID == parentID && oldRetainedIndex == newRetainedIndex { continue }

          let currentParentID = currentParentIDByID[newItem.id] ?? oldParentID
          let currentParent = currentParentID.flatMap { oldSnapshot.item(id: $0) ?? newSnapshot.item(id: $0) }
          let currentFromIndex = currentChildIDsByParent[currentParentID, default: []].firstIndex(of: newItem.id) ?? -1
          let currentParentChildCount = currentChildIDsByParent[currentParentID, default: []].count
          var currentAncestorID = parentID
          while let ancestorID = currentAncestorID {
            if ancestorID == newItem.id {
              logInvalidMoveIntoDescendant(
                oldItem: oldItem,
                newItem: newItem,
                fromParentID: currentParentID,
                toParentID: parentID,
              )
              applyImmediatelyAfterInvalidAnimatedUpdate()
              return
            }

            currentAncestorID = currentParentIDByID[ancestorID] ?? nil
          }
          let currentToSiblings = currentParentID == parentID
            ? currentChildIDsByParent[parentID, default: []].filter { $0 != newItem.id }
            : currentChildIDsByParent[parentID, default: []]
          let currentToIndex = currentToSiblings
            .firstIndex { siblingID in
              guard let siblingTargetIndex = targetIndexesByID[siblingID] else {
                return false
              }

              return siblingTargetIndex > targetIndex
            }
            ?? currentToSiblings.count

          if currentParentID == parentID && currentFromIndex == currentToIndex { continue }

          // The item is no longer at the expected current from index under its current parent.
          if currentFromIndex < 0 || currentFromIndex >= currentParentChildCount {
            logInvalidMoveFrom(
              oldItem: oldItem,
              newItem: newItem,
              fromIndex: currentFromIndex,
              toIndex: currentToIndex,
              fromParentChildCount: currentParentChildCount,
              fromParentID: currentParentID,
              toParentID: parentID,
            )
            applyImmediatelyAfterInvalidAnimatedUpdate()
            return
          }

          let toParentChildCount = currentToSiblings.count
          let maxToIndex = toParentChildCount
          // The requested to index is outside the current to parent bounds.
          if currentToIndex > maxToIndex {
            logInvalidMoveTo(
              oldItem: oldItem,
              newItem: newItem,
              toIndex: currentToIndex,
              maxToIndex: maxToIndex,
              fromParentID: currentParentID,
              toParentID: parentID,
            )
            applyImmediatelyAfterInvalidAnimatedUpdate()
            return
          }

          outlineView.moveItem(
            at: currentFromIndex,
            inParent: currentParent,
            to: currentToIndex,
            inParent: newParent,
          )
          movedIDs.insert(newItem.id)

          if currentParentID == parentID {
            currentChildIDsByParent[parentID, default: []].remove(at: currentFromIndex)
            currentChildIDsByParent[parentID, default: []].insert(newItem.id, at: currentToIndex)
          } else {
            currentChildIDsByParent[currentParentID, default: []].remove(at: currentFromIndex)
            currentChildIDsByParent[parentID, default: []].insert(newItem.id, at: currentToIndex)
            currentParentIDByID[newItem.id] = parentID
          }
        }
      }

      if
        !applyInsertions(
          shouldInsert: { targetIndex, newChildren, newItem in
            newItem.children.isEmpty && !newChildren.dropFirst(targetIndex + 1).contains {
              retainedIDs.contains($0.id)
            }
          },
          insertingBeforeRetainedSiblings: false,
        )
      {
        return
      }

      for parentID in oldSnapshot.orderedParentIDs.reversed() {
        if let parentID, removedIDs.contains(parentID) { continue }

        let removedChildren = oldSnapshot.children(parentID: parentID)
          .filter { removedIDs.contains($0.id) }

        for oldItem in removedChildren.reversed() {
          let currentParentID = currentParentIDByID[oldItem.id] ?? oldSnapshot.parentID(id: oldItem.id)
          let currentParent = currentParentID.flatMap { oldSnapshot.item(id: $0) ?? newSnapshot.item(id: $0) }
          let currentIndex = currentChildIDsByParent[currentParentID, default: []].firstIndex(of: oldItem.id) ?? -1
          let currentParentChildCount = currentChildIDsByParent[currentParentID, default: []].count
          // The row is no longer under the expected parent/index, so removing by the planned coordinates is unsafe.
          if currentParentID != parentID || currentIndex < 0 || currentIndex >= currentParentChildCount {
            logInvalidRemove(
              oldItem: oldItem,
              expectedParentID: parentID,
              currentParentID: currentParentID,
              currentIndex: currentIndex,
              currentParentChildCount: currentParentChildCount,
            )
            applyImmediatelyAfterInvalidAnimatedUpdate()
            return
          }

          outlineView.removeItems(
            at: IndexSet(integer: currentIndex),
            inParent: currentParent,
            withAnimation: removalAnimationOptions,
          )
          currentChildIDsByParent[currentParentID, default: []].remove(at: currentIndex)
          currentParentIDByID.removeValue(forKey: oldItem.id)
        }
      }

      let unchangedStructureIDs = retainedIDs.subtracting(movedIDs)
      let reloadCandidateIDs = unchangedStructureIDs.union(movedIDs)
      var reloadedItems = [OutlineItem<Item>]()
      var reloadedRows = IndexSet()
      var views = [NSView]()
      for id in reloadCandidateIDs {
        let oldValue = oldSnapshot.item(id: id)?.value
        let newValue = newSnapshot.item(id: id)?.value
        if oldValue == newValue { continue }

        guard let newItem = newSnapshot.item(id: id) else { continue }

        reloadedItems.append(newItem)

        let row = outlineView.row(forItem: newItem)
        if row == -1 { continue }
        reloadedRows.insert(row)
        let view = outlineView.rowView(atRow: row, makeIfNecessary: false)
        if let view {
          views.append(view)
        }
      }
      // without this in the completion handler, cell sizes are fucked up
      NSAnimationContext.current.completionHandler = {
        for item in reloadedItems {
          outlineView.reloadItem(item)
        }
      }

      outlineView.endUpdates()
      outlineView.noteHeightOfRows(withIndexesChanged: reloadedRows)

      didBeginUpdates = false

      fallbackSnapshot = nil
      completion?(true)
    }

    if animatingDifferences {
      applyWithAnimation()
    } else {
      applyImmediately()
    }
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
    if isFallbackItem(item) {
      return fallbackItem
    }

    let currentChildren = currentSnapshot.children(of: item)
    if index < currentChildren.count {
      return currentChildren[index]
    }

    let fallbackChildren = fallbackSnapshot?.children(of: item) ?? []
    if index < fallbackChildren.count {
      return fallbackChildren[index]
    }

    return fallbackItem
  }

  public func outlineView(_: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if isFallbackItem(item) { return 0 }
    return max(currentSnapshot.children(of: item).count, fallbackSnapshot?.children(of: item).count ?? 0)
  }

  public func outlineView(_: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if isFallbackItem(item) { return false }
    return (currentSnapshot.outlineItem(for: item) ?? fallbackSnapshot?.outlineItem(for: item))
      .map(\.value)
      .flatMap { isExpandable?($0) } ?? false
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

  // TODO: work in progress
  enum UpdatePhase {
    case reload
    case insertions
    case removals
    case moves
  }

  let insertionAnimationOptions: NSTableView.AnimationOptions = [.effectFade, .slideDown]
  let removalAnimationOptions: NSTableView.AnimationOptions = [.effectFade, .slideDown]

  // MARK: Private

  private final class FallbackItem: NSObject { }

  private weak var outlineView: NSOutlineView?
  private var currentSnapshot = OutlineViewDiffableSnapshot<Item>()
  private var fallbackSnapshot: OutlineViewDiffableSnapshot<Item>?
  private let fallbackItem = FallbackItem()

}

extension OutlineViewDiffableDataSource {
  private func logInvalidInsert(
    newItem: OutlineItem<Item>,
    toIndex: Int,
    currentChildCount: Int,
    parentID: Item.ID?,
  ) {
    outlineViewDiffableLogMessage(
      """
      OUTLINE DIFF INVALID INSERT
      REASON: Snapshot requested an insertion beyond the current sibling count.
      NEW_ITEM: \(String(describing: newItem))
      TO_INDEX: \(toIndex)
      CURRENT_CHILD_COUNT: \(currentChildCount)
      PARENT_ID: \(String(describing: parentID))
      """
    )
  }

  private func logInvalidRemove(
    oldItem: OutlineItem<Item>,
    expectedParentID: Item.ID?,
    currentParentID: Item.ID?,
    currentIndex: Int,
    currentParentChildCount: Int,
  ) {
    outlineViewDiffableLogMessage(
      """
      OUTLINE DIFF INVALID REMOVE
      REASON: Row is no longer under the expected parent or index.
      OLD_ITEM: \(String(describing: oldItem))
      EXPECTED_PARENT_ID: \(String(describing: expectedParentID))
      CURRENT_PARENT_ID: \(String(describing: currentParentID))
      CURRENT_INDEX: \(currentIndex)
      CURRENT_PARENT_CHILD_COUNT: \(currentParentChildCount)
      """
    )
  }

  private func logInvalidMoveFrom(
    oldItem: OutlineItem<Item>,
    newItem: OutlineItem<Item>,
    fromIndex: Int,
    toIndex: Int,
    fromParentChildCount: Int,
    fromParentID: Item.ID?,
    toParentID: Item.ID?,
  ) {
    outlineViewDiffableLogMessage(
      """
      OUTLINE DIFF INVALID MOVE FROM
      REASON: Item is no longer at the expected FROM index under its current parent.
      OLD_ITEM: \(String(describing: oldItem))
      NEW_ITEM: \(String(describing: newItem))
      FROM_INDEX: \(fromIndex)
      TO_INDEX: \(toIndex)
      FROM_PARENT_CHILD_COUNT: \(fromParentChildCount)
      FROM_PARENT_ID: \(String(describing: fromParentID))
      TO_PARENT_ID: \(String(describing: toParentID))
      """
    )
  }

  private func logInvalidMoveTo(
    oldItem: OutlineItem<Item>,
    newItem: OutlineItem<Item>,
    toIndex: Int,
    maxToIndex: Int,
    fromParentID: Item.ID?,
    toParentID: Item.ID?,
  ) {
    outlineViewDiffableLogMessage(
      """
      OUTLINE DIFF INVALID MOVE TO
      REASON: Requested TO index is outside the current TO parent bounds.
      OLD_ITEM: \(String(describing: oldItem))
      NEW_ITEM: \(String(describing: newItem))
      TO_INDEX: \(toIndex)
      MAX_TO_INDEX: \(maxToIndex)
      FROM_PARENT_ID: \(String(describing: fromParentID))
      TO_PARENT_ID: \(String(describing: toParentID))
      """
    )
  }

  private func logInvalidMoveIntoDescendant(
    oldItem: OutlineItem<Item>,
    newItem: OutlineItem<Item>,
    fromParentID: Item.ID?,
    toParentID: Item.ID?,
  ) {
    outlineViewDiffableLogMessage(
      """
      OUTLINE DIFF INVALID MOVE INTO DESCENDANT
      REASON: Item would be moved under one of its current descendants.
      OLD_ITEM: \(String(describing: oldItem))
      NEW_ITEM: \(String(describing: newItem))
      FROM_PARENT_ID: \(String(describing: fromParentID))
      TO_PARENT_ID: \(String(describing: toParentID))
      """
    )
  }
}
