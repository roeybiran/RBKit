import Testing

@testable import RBKit

struct `OutlineViewDiffableOperation Tests` {

  // MARK: Internal

  @Test
  func `operations(to:) with appended root item, should insert it after its predecessor`() {
    #expect(operations(from: [.init(id: 0)], to: [.init(id: 0), .init(id: 1)]) == [.insert(index: 1, parentID: nil)])
  }

  @Test
  func `operations(to:) with removed sibling before retained item, should only remove`() {
    #expect(
      operations(from: [.init(id: 0), .init(id: 1), .init(id: 2)], to: [.init(id: 0), .init(id: 2)])
        == [.remove(index: 1, parentID: nil)]
    )
  }

  @Test
  func `operations(to:) with removed subtree, should only remove its root`() {
    #expect(
      operations(from: [.init(id: 0, children: [.init(id: 1, children: [.init(id: 2)])])], to: [])
        == [.remove(index: 0, parentID: nil)]
    )
  }

  @Test
  func `operations(to:) with one item moved across many siblings, should only move that item`() {
    #expect(
      operations(
        from: [.init(id: 0), .init(id: 1), .init(id: 2), .init(id: 3)],
        to: [.init(id: 3), .init(id: 0), .init(id: 1), .init(id: 2)],
      ) == [.move(fromIndex: 3, fromParentID: nil, toIndex: 0, toParentID: nil)]
    )
  }

  @Test
  func `operations(to:) with reparented item, should move it between parents`() {
    #expect(
      operations(
        from: [.init(id: 0, children: [.init(id: 1), .init(id: 2)]), .init(id: 3)],
        to: [.init(id: 0, children: [.init(id: 1)]), .init(id: 3, children: [.init(id: 2)])],
      ) == [.move(fromIndex: 1, fromParentID: 0, toIndex: 0, toParentID: 3)]
    )
  }

  @Test
  func `operations(to:) with parent and child swapping places, should move the child out first`() {
    #expect(
      operations(from: [.init(id: 0, children: [.init(id: 1)])], to: [.init(id: 1, children: [.init(id: 0)])])
        == [
          .move(fromIndex: 0, fromParentID: 0, toIndex: 0, toParentID: nil),
          .move(fromIndex: 1, fromParentID: nil, toIndex: 0, toParentID: 1),
        ]
    )
  }

  @Test
  func `operations(to:) with retained item moved below an inserted item, should remove it instead of moving it`() {
    #expect(
      operations(from: [.init(id: 0), .init(id: 1)], to: [.init(id: 0), .init(id: 2, children: [.init(id: 1)])])
        == [
          .insert(index: 1, parentID: nil),
          .remove(index: 2, parentID: nil),
        ]
    )
  }

  @Test
  func `operations(to:) with retained item moved out of a removed item, should move it before removing`() {
    #expect(
      operations(from: [.init(id: 0, children: [.init(id: 1)])], to: [.init(id: 1)])
        == [
          .move(fromIndex: 0, fromParentID: 0, toIndex: 0, toParentID: nil),
          .remove(index: 1, parentID: nil),
        ]
    )
  }

  @Test
  func `operations(to:) with only value changes, should return no operations`() {
    #expect(
      operations(
        from: [.init(id: 0, version: 0, children: [.init(id: 1, version: 0)])],
        to: [.init(id: 0, version: 1, children: [.init(id: 1, version: 1)])],
      ) == []
    )
  }

  @Test
  func `operations(to:) with exhaustive three node forests, should transform every forest into every other`() {
    let forests = outlineViewDiffableTestForests(of: [0, 1, 2])

    #expect(forests.count == 46)

    for fromNodes in forests {
      for toNodes in forests {
        if let issue = issue(from: fromNodes, to: toNodes) {
          Issue.record("\(issue)\nfrom: \(fromNodes.forestDescription)\nto: \(toNodes.forestDescription)")
          return
        }
      }
    }
  }

  @Test(arguments: [8, 16, 48])
  func `operations(to:) with random forests, should transform every forest into the next`(idCount: Int) {
    var generator = OutlineViewDiffableTestRandomNumberGenerator(seed: UInt64(idCount))
    var fromNodes = [OutlineViewDiffableTestNode]()

    for _ in 0..<2000 {
      let toNodes = [OutlineViewDiffableTestNode].random(idCount: idCount, using: &generator)
      if let issue = issue(from: fromNodes, to: toNodes) {
        Issue.record("\(issue)\nfrom: \(fromNodes.forestDescription)\nto: \(toNodes.forestDescription)")
        return
      }
      fromNodes = toNodes
    }
  }

  @Test
  func `longestIncreasingSubsequenceOffsets(in:) should return the offsets of a longest increasing subsequence`() {
    #expect(longestIncreasingSubsequenceOffsets(in: []) == [])
    #expect(longestIncreasingSubsequenceOffsets(in: [0, 1, 2]) == [0, 1, 2])
    #expect(longestIncreasingSubsequenceOffsets(in: [2, 1, 0]).count == 1)
    #expect(longestIncreasingSubsequenceOffsets(in: [3, 0, 1, 2]) == [1, 2, 3])
    #expect(longestIncreasingSubsequenceOffsets(in: [0, 4, 1, 5, 2, 3]) == [0, 2, 4, 5])
  }

  // MARK: Private

  private typealias Node = OutlineViewDiffableTestNode

  private enum Entry: Equatable {
    case existing(Int)
    case inserted
  }

  private func snapshot(_ nodes: [Node]) -> OutlineViewDiffableSnapshot<Node> {
    var snapshot = OutlineViewDiffableSnapshot<Node>()
    snapshot.append(items: nodes)
    return snapshot
  }

  private func operations(from fromNodes: [Node], to toNodes: [Node]) -> [OutlineViewDiffableOperation<Int>]? {
    snapshot(fromNodes).operations(to: snapshot(toNodes))
  }

  private func issue(from fromNodes: [Node], to toNodes: [Node]) -> String? {
    guard let operations = operations(from: fromNodes, to: toNodes) else { return "no operations" }

    var entriesByParentID = [Int?: [Entry]]()
    var parentIDByID = [Int: Int?]()

    func load(_ nodes: [Node], parentID: Int?) {
      entriesByParentID[parentID] = nodes.map { .existing($0.id) }
      for node in nodes {
        parentIDByID.updateValue(parentID, forKey: node.id)
        load(node.children.elements, parentID: node.id)
      }
    }

    func unload(_ id: Int) {
      parentIDByID.removeValue(forKey: id)
      for case .existing(let childID) in entriesByParentID.removeValue(forKey: id) ?? [] {
        unload(childID)
      }
    }

    func isLoaded(_ parentID: Int?) -> Bool {
      parentID.map { parentIDByID[$0] != nil } ?? true
    }

    load(fromNodes, parentID: nil)
    let oldIDs = Set(parentIDByID.keys)

    for operation in operations {
      switch operation {
      case .insert(let index, let parentID):
        guard isLoaded(parentID), index >= 0, index <= entriesByParentID[parentID, default: []].count else {
          return "invalid \(operation)"
        }

        entriesByParentID[parentID, default: []].insert(.inserted, at: index)

      case .remove(let index, let parentID):
        guard
          isLoaded(parentID),
          entriesByParentID[parentID, default: []].indices.contains(index),
          case .existing(let id) = entriesByParentID[parentID, default: []][index]
        else {
          return "invalid \(operation)"
        }

        entriesByParentID[parentID]?.remove(at: index)
        unload(id)

      case .move(let fromIndex, let fromParentID, let toIndex, let toParentID):
        guard
          isLoaded(fromParentID),
          isLoaded(toParentID),
          entriesByParentID[fromParentID, default: []].indices.contains(fromIndex),
          case .existing(let id) = entriesByParentID[fromParentID, default: []][fromIndex]
        else {
          return "invalid \(operation)"
        }

        var ancestorID = toParentID
        while let currentID = ancestorID {
          if currentID == id { return "\(operation) moves an item into itself" }
          ancestorID = parentIDByID[currentID] ?? nil
        }

        entriesByParentID[fromParentID]?.remove(at: fromIndex)
        guard toIndex >= 0, toIndex <= entriesByParentID[toParentID, default: []].count else {
          return "invalid \(operation)"
        }

        entriesByParentID[toParentID, default: []].insert(.existing(id), at: toIndex)
        parentIDByID.updateValue(toParentID, forKey: id)
      }
    }

    func mismatch(_ nodes: [Node], parentID: Int?) -> String? {
      let entries = entriesByParentID[parentID] ?? []
      guard entries.count == nodes.count else {
        return "\(parentID.map { "\($0)" } ?? "root") has \(entries.count) children instead of \(nodes.count)"
      }

      for (entry, node) in zip(entries, nodes) {
        switch entry {
        case .existing(let id):
          if id != node.id { return "found \(id) instead of \(node.id)" }
          if let mismatch = mismatch(node.children.elements, parentID: id) { return mismatch }

        case .inserted:
          if oldIDs.contains(node.id) { return "\(node.id) was inserted instead of moved" }
          if let id = [node].preorderIDs.first(where: { parentIDByID[$0] != nil }) {
            return "\(id) is in the tree twice"
          }
        }
      }

      return nil
    }

    if let mismatch = mismatch(toNodes, parentID: nil) { return "\(mismatch) after \(operations)" }
    if fromNodes.preorderIDs == toNodes.preorderIDs, snapshot(fromNodes).ids == snapshot(toNodes).ids {
      let hasSameStructure = fromNodes.forestDescription == toNodes.forestDescription
      if hasSameStructure, !operations.isEmpty { return "unnecessary \(operations)" }
    }
    return nil
  }
}
