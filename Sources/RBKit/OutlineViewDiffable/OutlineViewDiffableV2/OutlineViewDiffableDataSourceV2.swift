import AppKit

// MARK: - OutlineViewDiffableDataSourceV2

@MainActor
public final class OutlineViewDiffableDataSourceV2<Item: TreeNodeProtocol & Hashable & Sendable>: NSObject,
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
    _ snapshot: OutlineViewDiffableSnapshotV2<Item>,
    animatingDifferences: Bool,
    completion: ((_ didApply: Bool) -> Void)? = nil,
  ) {
    let oldSnapshot = currentSnapshot
    let newSnapshot = snapshot

    guard let outlineView else {
      updatePhase = .reload
      currentSnapshot = newSnapshot
      fallbackSnapshot = nil
      completion?(true)
      return
    }

    if oldSnapshot.hasSameValues(as: newSnapshot) {
      updatePhase = .reload
      currentSnapshot = newSnapshot
      fallbackSnapshot = nil
      completion?(false)
      return
    }

    func applyImmediately() {
      updatePhase = .reload
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
      let oldComparisonDataByID = oldSnapshot.comparisonDataByID
      let newComparisonDataByID = newSnapshot.comparisonDataByID
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
      var animationGroupingDepth = 0

      func beginAnimationGrouping() {
        NSAnimationContext.beginGrouping()
        animationGroupingDepth += 1
      }

      func endAnimationGrouping() {
        guard animationGroupingDepth > 0 else { return }
        animationGroupingDepth -= 1
        NSAnimationContext.endGrouping()
      }

      func endAllAnimationGroupings() {
        while animationGroupingDepth > 0 {
          endAnimationGrouping()
        }
      }

      func applyImmediatelyAfterInvalidAnimatedUpdate() -> Bool {
        updatePhase = .reload

        if didBeginUpdates {
          outlineView.endUpdates()
          didBeginUpdates = false
        }

        endAllAnimationGroupings()
        applyImmediately()
        return false
      }

      fallbackSnapshot = oldSnapshot
      currentSnapshot = newSnapshot

      beginAnimationGrouping()
      outlineView.beginUpdates()
      didBeginUpdates = true

      updatePhase = .removals
      beginAnimationGrouping()

      for parentID in oldSnapshot.orderedParentIDs.reversed() {
        if let parentID, removedIDs.contains(parentID) { continue }

        let removedChildren = oldSnapshot.children(parentID: parentID)
          .filter { removedIDs.contains($0.id) }

        for oldItem in removedChildren.reversed() {
          let currentParentID = currentParentIDByID[oldItem.id] ?? oldSnapshot.parentID(id: oldItem.id)
          let currentParent = currentParentID.flatMap { oldSnapshot.item(id: $0) ?? newSnapshot.item(id: $0) }
          let currentIndex = currentChildIDsByParent[currentParentID, default: []].firstIndex(of: oldItem.id) ?? -1
          let currentParentChildCount = currentChildIDsByParent[currentParentID, default: []].count

          if currentParentID != parentID || currentIndex < 0 || currentIndex >= currentParentChildCount {
            logInvalidRemove(
              oldItem: oldItem,
              expectedParentID: parentID,
              currentParentID: currentParentID,
              currentIndex: currentIndex,
              currentParentChildCount: currentParentChildCount,
            )
            if !applyImmediatelyAfterInvalidAnimatedUpdate() {
              return
            }
          }

          outlineView.removeItems(
            at: IndexSet(integer: currentIndex),
            inParent: currentParent,
            withAnimation: removalAnimationOptions,
          )
          currentChildIDsByParent[currentParentID, default: []].remove(at: currentIndex)
          currentParentIDByID.removeValue(forKey: oldItem.id)
          currentChildIDsByParent.removeValue(forKey: oldItem.id)

          for descendantID in oldComparisonDataByID[oldItem.id]?.descendantsByID ?? [] {
            currentParentIDByID.removeValue(forKey: descendantID)
            currentChildIDsByParent.removeValue(forKey: descendantID)
          }
        }
      }

      endAnimationGrouping()

      updatePhase = .insertions
      beginAnimationGrouping()

      for parentID in newSnapshot.orderedParentIDs {
        if let parentID, insertedIDs.contains(parentID) { continue }

        let newParent = parentID.flatMap { oldSnapshot.item(id: $0) ?? newSnapshot.item(id: $0) }
        let newChildren = newSnapshot.children(parentID: parentID)
        let targetIndexesByID = Dictionary(
          uniqueKeysWithValues: newChildren.enumerated().map { index, item in
            (item.id, index)
          }
        )

        for (targetIndex, newItem) in newChildren.enumerated() where insertedIDs.contains(newItem.id) {
          let currentInsertIndex = currentChildIDsByParent[parentID, default: []]
            .firstIndex { currentChildID in
              guard let currentTargetIndex = targetIndexesByID[currentChildID] else {
                return false
              }

              return currentTargetIndex > targetIndex
            }
            ?? currentChildIDsByParent[parentID, default: []].count
          let currentChildCount = outlineView.numberOfChildren(ofItem: newParent)

          if currentInsertIndex > currentChildCount {
            logInvalidInsert(
              newItem: newItem,
              toIndex: currentInsertIndex,
              currentChildCount: currentChildCount,
              parentID: parentID,
            )
            if !applyImmediatelyAfterInvalidAnimatedUpdate() {
              return
            }
          }

          outlineView.insertItems(
            at: IndexSet(integer: currentInsertIndex),
            inParent: newParent,
            withAnimation: insertionAnimationOptions,
          )
          currentChildIDsByParent[parentID, default: []].insert(newItem.id, at: currentInsertIndex)
          currentParentIDByID[newItem.id] = parentID
          currentChildIDsByParent[newItem.id] = newSnapshot.children(parentID: newItem.id)
            .filter { insertedIDs.contains($0.id) }
            .map(\.id)

          for descendantID in newComparisonDataByID[newItem.id]?.descendantsByID ?? [] {
            guard insertedIDs.contains(descendantID) else { continue }
            guard let comparisonData = newComparisonDataByID[descendantID] else { continue }

            currentParentIDByID[descendantID] = comparisonData.parentID
            currentChildIDsByParent[descendantID] = newSnapshot.children(parentID: descendantID)
              .filter { insertedIDs.contains($0.id) }
              .map(\.id)
          }
        }
      }

      endAnimationGrouping()

      updatePhase = .moves
      beginAnimationGrouping()

      for parentID in newSnapshot.orderedParentIDs {
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
              if !applyImmediatelyAfterInvalidAnimatedUpdate() {
                return
              }
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
            if !applyImmediatelyAfterInvalidAnimatedUpdate() {
              return
            }
          }

          let maxToIndex = currentToSiblings.count

          if currentToIndex > maxToIndex {
            logInvalidMoveTo(
              oldItem: oldItem,
              newItem: newItem,
              toIndex: currentToIndex,
              maxToIndex: maxToIndex,
              fromParentID: currentParentID,
              toParentID: parentID,
            )
            if !applyImmediatelyAfterInvalidAnimatedUpdate() {
              return
            }
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

      endAnimationGrouping()

      updatePhase = .reload
      var reloadedItems = [DiffableOutlineItem<Item>]()
      let unchangedStructureIDs = retainedIDs.subtracting(movedIDs)
      let reloadCandidateIDs = unchangedStructureIDs.union(movedIDs)

      for id in reloadCandidateIDs {
        let oldValue = oldSnapshot.item(id: id)?.value
        let newValue = newSnapshot.item(id: id)?.value
        if oldValue == newValue { continue }
        guard let newItem = newSnapshot.item(id: id) else { continue }

        outlineView.reloadItem(newItem)
        reloadedItems.append(newItem)
      }

      outlineView.endUpdates()
      didBeginUpdates = false
      endAnimationGrouping()

      let reloadedRows = reloadedItems.reduce(into: IndexSet()) { result, item in
        let row = outlineView.row(forItem: item)
        if row >= 0 {
          result.insert(row)
        }
      }
      outlineView.noteHeightOfRows(withIndexesChanged: reloadedRows)
      fallbackSnapshot = nil
      updatePhase = .reload
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

    let primaryChildren: [DiffableOutlineItem<Item>]
    let secondaryChildren: [DiffableOutlineItem<Item>]

    switch updatePhase {
    case .reload, .insertions:
      primaryChildren = currentSnapshot.children(of: item)
      secondaryChildren = []

    case .removals:
      primaryChildren = (fallbackSnapshot ?? currentSnapshot).children(of: item)
      secondaryChildren = []

    case .moves:
      primaryChildren = fallbackSnapshot?.children(of: item) ?? currentSnapshot.children(of: item)
      secondaryChildren = fallbackSnapshot == nil ? [] : currentSnapshot.children(of: item)
    }

    if index < primaryChildren.count {
      return primaryChildren[index]
    }

    if index < secondaryChildren.count {
      return secondaryChildren[index]
    }

    return fallbackItem
  }

  public func outlineView(_: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    if isFallbackItem(item) { return 0 }

    switch updatePhase {
    case .reload, .insertions:
      return currentSnapshot.children(of: item).count
    case .removals:
      return (fallbackSnapshot ?? currentSnapshot).children(of: item).count
    case .moves:
      return max(
        fallbackSnapshot?.children(of: item).count ?? 0,
        currentSnapshot.children(of: item).count,
      )
    }
  }

  public func outlineView(_: NSOutlineView, isItemExpandable item: Any) -> Bool {
    if isFallbackItem(item) { return false }

    let outlineItem: DiffableOutlineItem<Item>? =
      switch updatePhase {
      case .reload, .insertions:
        currentSnapshot.outlineItem(for: item)
      case .removals:
        (fallbackSnapshot ?? currentSnapshot).outlineItem(for: item)
      case .moves:
        fallbackSnapshot?.outlineItem(for: item) ?? currentSnapshot.outlineItem(for: item)
      }

    return outlineItem.map(\.value).flatMap { isExpandable?($0) } ?? false
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

  enum UpdatePhase {
    case reload
    case removals
    case insertions
    case moves
  }

  let insertionAnimationOptions: NSTableView.AnimationOptions = [.effectFade, .slideDown]
  let removalAnimationOptions: NSTableView.AnimationOptions = [.effectFade, .slideDown]

  // MARK: Private

  private final class FallbackItem: NSObject { }

  private weak var outlineView: NSOutlineView?
  private var currentSnapshot = OutlineViewDiffableSnapshotV2<Item>()
  private var fallbackSnapshot: OutlineViewDiffableSnapshotV2<Item>?
  private var updatePhase = UpdatePhase.reload
  private let fallbackItem = FallbackItem()
}

// MARK: - OutlineViewDiffableDataSourceV2+

extension OutlineViewDiffableDataSourceV2 {
  private func logInvalidInsert(
    newItem: DiffableOutlineItem<Item>,
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
    oldItem: DiffableOutlineItem<Item>,
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
    oldItem: DiffableOutlineItem<Item>,
    newItem: DiffableOutlineItem<Item>,
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
    oldItem: DiffableOutlineItem<Item>,
    newItem: DiffableOutlineItem<Item>,
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
    oldItem: DiffableOutlineItem<Item>,
    newItem: DiffableOutlineItem<Item>,
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
