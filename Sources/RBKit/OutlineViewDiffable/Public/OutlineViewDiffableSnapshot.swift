public struct OutlineViewDiffableSnapshot<Item: TreeNodeProtocol & Hashable & Sendable> {

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

  var ids: Set<OutlineItem<Item>.ID> {
    Set(flattenedTree.keys)
  }

  var orderedParentIDs: [OutlineItem<Item>.ID?] {
    parentOrder
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
