// MARK: - OutlineViewDiffableOperation

enum OutlineViewDiffableOperation<ID: Hashable>: Hashable {
  case insert(index: Int, parentID: ID?)
  case remove(index: Int, parentID: ID?)
  case move(fromIndex: Int, fromParentID: ID?, toIndex: Int, toParentID: ID?)
}

// MARK: - OutlineViewDiffableSnapshot + operations

extension OutlineViewDiffableSnapshot {
  func operations(to newSnapshot: Self) -> [OutlineViewDiffableOperation<Item.ID>]? {
    typealias ID = Item.ID

    let oldIDs = ids
    let newIDs = newSnapshot.ids

    var freshIDs = Set<ID>()
    for parentID in newSnapshot.orderedParentIDs {
      let isParentFresh = parentID.map(freshIDs.contains) ?? false
      for child in newSnapshot.children(parentID: parentID) where isParentFresh || !oldIDs.contains(child.id) {
        freshIDs.insert(child.id)
      }
    }

    var childIDsByParentID = [ID?: [ID]]()
    var parentIDByID = [ID: ID?]()
    for parentID in orderedParentIDs {
      let childIDs = children(parentID: parentID).map(\.id)
      if childIDs.isEmpty { continue }
      childIDsByParentID[parentID] = childIDs
      for id in childIDs {
        parentIDByID.updateValue(parentID, forKey: id)
      }
    }

    var operations = [OutlineViewDiffableOperation<ID>]()

    for parentID in newSnapshot.orderedParentIDs {
      if let parentID, freshIDs.contains(parentID) { continue }

      let targetIDs = newSnapshot.children(parentID: parentID).map(\.id)
      if targetIDs.isEmpty { continue }

      var targetIndexByID = [ID: Int]()
      for (index, id) in targetIDs.enumerated() {
        targetIndexByID[id] = index
      }

      let currentTargetIndexes = childIDsByParentID[parentID, default: []].compactMap { targetIndexByID[$0] }
      let stableIDs = Set(
        longestIncreasingSubsequenceOffsets(in: currentTargetIndexes).map { targetIDs[currentTargetIndexes[$0]] }
      )

      var previousID: ID?
      for id in targetIDs {
        defer { previousID = id }
        if stableIDs.contains(id) { continue }

        var fromParentID: ID??
        var fromIndex: Int?
        if !freshIDs.contains(id) {
          guard
            let currentParentID = parentIDByID[id],
            let currentIndex = childIDsByParentID[currentParentID]?.firstIndex(of: id)
          else {
            return nil
          }

          childIDsByParentID[currentParentID]?.remove(at: currentIndex)
          fromParentID = currentParentID
          fromIndex = currentIndex
        }

        var toIndex = 0
        if let previousID {
          guard let previousIndex = childIDsByParentID[parentID]?.firstIndex(of: previousID) else { return nil }
          toIndex = previousIndex + 1
        }

        childIDsByParentID[parentID, default: []].insert(id, at: toIndex)
        parentIDByID.updateValue(parentID, forKey: id)

        if let fromParentID, let fromIndex {
          operations.append(
            .move(fromIndex: fromIndex, fromParentID: fromParentID, toIndex: toIndex, toParentID: parentID)
          )
        } else {
          operations.append(.insert(index: toIndex, parentID: parentID))
        }
      }
    }

    let removedIDs = oldIDs.filter { !newIDs.contains($0) || freshIDs.contains($0) }
    if removedIDs.isEmpty { return operations }

    for parentID in newSnapshot.orderedParentIDs {
      if let parentID, freshIDs.contains(parentID) { continue }
      guard let childIDs = childIDsByParentID[parentID] else { continue }

      for index in childIDs.indices.reversed() where removedIDs.contains(childIDs[index]) {
        operations.append(.remove(index: index, parentID: parentID))
      }
    }

    return operations
  }
}

func longestIncreasingSubsequenceOffsets(in values: [Int]) -> [Int] {
  var tails = [Int]()
  var predecessors = [Int?](repeating: nil, count: values.count)

  for (offset, value) in values.enumerated() {
    var low = 0
    var high = tails.count
    while low < high {
      let middle = (low + high) / 2
      if values[tails[middle]] < value {
        low = middle + 1
      } else {
        high = middle
      }
    }

    predecessors[offset] = low > 0 ? tails[low - 1] : nil
    if low == tails.count {
      tails.append(offset)
    } else {
      tails[low] = offset
    }
  }

  var offsets = [Int]()
  var current = tails.last
  while let offset = current {
    offsets.append(offset)
    current = predecessors[offset]
  }
  return offsets.reversed()
}
