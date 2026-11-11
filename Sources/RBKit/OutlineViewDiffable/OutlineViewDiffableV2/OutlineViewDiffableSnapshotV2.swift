public struct OutlineViewDiffableSnapshotV2<Item: TreeNodeProtocol & Hashable & Sendable> {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public mutating func append(items: [Item]) {
    func makeOutlineItem(_ item: Item) -> OutlineItem<Item> {
      .init(item, children: item.children.map(makeOutlineItem))
    }

    let originalTree = items.map(makeOutlineItem)

    var childrenByParent = [OutlineItem<Item>.ID?: [OutlineItem<Item>]]()
    var childIndexByID = [OutlineItem<Item>.ID: Int]()
    var parentOrder = [OutlineItem<Item>.ID?]()
    var flattenedTree = [OutlineItem<Item>.ID: OutlineItem<Item>]()
    var parentByID = [OutlineItem<Item>.ID: OutlineItem<Item>.ID?]()

    func append(_ items: [OutlineItem<Item>], parentID: OutlineItem<Item>.ID?) {
      childrenByParent[parentID] = items
      parentOrder.append(parentID)

      for (index, item) in items.enumerated() {
        childIndexByID[item.id] = index
        flattenedTree[item.id] = item
        parentByID[item.id] = parentID
        append(item.children, parentID: item.id)
      }
    }

    append(originalTree, parentID: nil)

    self.childIndexByID = childIndexByID
    self.originalTree = originalTree
    self.childrenByParent = childrenByParent
    self.parentByID = parentByID
    self.parentOrder = parentOrder
    self.flattenedTree = flattenedTree
    values = items
  }

  // MARK: Internal

  struct ComparisonData {
    var parentID: OutlineItem<Item>.ID?
    var index: Int
    var descendantsByID: Set<OutlineItem<Item>.ID>
    var isLeaf: Bool
  }

  var ids: Set<OutlineItem<Item>.ID> {
    Set(flattenedTree.keys)
  }

  var orderedParentIDs: [OutlineItem<Item>.ID?] {
    parentOrder
  }

  var comparisonDataByID: [OutlineItem<Item>.ID: ComparisonData] {
    var comparisonDataByID = [OutlineItem<Item>.ID: ComparisonData]()

    func append(
      _ item: OutlineItem<Item>,
      parentID: OutlineItem<Item>.ID?,
      index: Int,
    ) -> Set<OutlineItem<Item>.ID> {
      var descendantsByID = Set<OutlineItem<Item>.ID>()

      for (childIndex, child) in item.children.enumerated() {
        descendantsByID.insert(child.id)
        descendantsByID.formUnion(
          append(
            child,
            parentID: item.id,
            index: childIndex,
          )
        )
      }

      comparisonDataByID[item.id] = .init(
        parentID: parentID,
        index: index,
        descendantsByID: descendantsByID,
        isLeaf: item.children.isEmpty,
      )

      return descendantsByID
    }

    for (index, item) in originalTree.enumerated() {
      _ = append(item, parentID: nil, index: index)
    }

    return comparisonDataByID
  }

  subscript(_ index: Int) -> OutlineItem<Item> {
    originalTree[index]
  }

  func outlineItem(for item: Any?) -> OutlineItem<Item>? {
    guard let item = item as? OutlineItem<Item> else { return nil }
    return flattenedTree[item.id]
  }

  func children(of item: Any?) -> [OutlineItem<Item>] {
    if let item = outlineItem(for: item) {
      return item.children
    }
    return originalTree
  }

  func children(parentID: OutlineItem<Item>.ID?) -> [OutlineItem<Item>] {
    childrenByParent[parentID] ?? []
  }

  func item(id: OutlineItem<Item>.ID) -> OutlineItem<Item>? {
    flattenedTree[id]
  }

  func childIndex(id: OutlineItem<Item>.ID) -> Int? {
    childIndexByID[id]
  }

  func hasSameValues(as other: Self) -> Bool {
    values == other.values
  }

  func parentID(id: OutlineItem<Item>.ID) -> OutlineItem<Item>.ID? {
    parentByID[id] ?? nil
  }

  // MARK: Private

  private var originalTree = [OutlineItem<Item>]()
  private var flattenedTree = [OutlineItem<Item>.ID: OutlineItem<Item>]()
  private var values = [Item]()
  private var childrenByParent = [OutlineItem<Item>.ID?: [OutlineItem<Item>]]()
  private var childIndexByID = [OutlineItem<Item>.ID: Int]()
  private var parentByID = [OutlineItem<Item>.ID: OutlineItem<Item>.ID?]()
  private var parentOrder = [OutlineItem<Item>.ID?]()
}
