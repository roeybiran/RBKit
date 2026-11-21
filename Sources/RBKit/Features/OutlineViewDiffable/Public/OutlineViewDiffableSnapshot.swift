public struct OutlineViewDiffableSnapshot<Item: TreeNodeProtocol & Hashable & Sendable> {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public mutating func append(items: [Item]) {
    func makeOutlineItem(_ item: Item) -> DiffableOutlineItem<Item> {
      .init(item, children: item.children.map(makeOutlineItem))
    }

    let originalTree = items.map(makeOutlineItem)

    var childrenByParent = [DiffableOutlineItem<Item>.ID?: [DiffableOutlineItem<Item>]]()
    var childIndexByID = [DiffableOutlineItem<Item>.ID: Int]()
    var parentOrder = [DiffableOutlineItem<Item>.ID?]()
    var flattenedTree = [DiffableOutlineItem<Item>.ID: DiffableOutlineItem<Item>]()
    var parentByID = [DiffableOutlineItem<Item>.ID: DiffableOutlineItem<Item>.ID?]()

    func append(_ items: [DiffableOutlineItem<Item>], parentID: DiffableOutlineItem<Item>.ID?) {
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

  var ids: Set<DiffableOutlineItem<Item>.ID> {
    Set(flattenedTree.keys)
  }

  var orderedParentIDs: [DiffableOutlineItem<Item>.ID?] {
    parentOrder
  }

  subscript(_ index: Int) -> DiffableOutlineItem<Item> {
    originalTree[index]
  }

  func outlineItem(for item: Any?) -> DiffableOutlineItem<Item>? {
    guard let item = item as? DiffableOutlineItem<Item> else { return nil }
    return flattenedTree[item.id]
  }

  func children(of item: Any?) -> [DiffableOutlineItem<Item>] {
    if let item = outlineItem(for: item) {
      return item.children
    }
    return originalTree
  }

  func children(parentID: DiffableOutlineItem<Item>.ID?) -> [DiffableOutlineItem<Item>] {
    childrenByParent[parentID] ?? []
  }

  func item(id: DiffableOutlineItem<Item>.ID) -> DiffableOutlineItem<Item>? {
    flattenedTree[id]
  }

  func childIndex(id: DiffableOutlineItem<Item>.ID) -> Int? {
    childIndexByID[id]
  }

  func hasSameValues(as other: Self) -> Bool {
    values == other.values
  }

  func parentID(id: DiffableOutlineItem<Item>.ID) -> DiffableOutlineItem<Item>.ID? {
    parentByID[id] ?? nil
  }

  // MARK: Private

  private var originalTree = [DiffableOutlineItem<Item>]()
  private var flattenedTree = [DiffableOutlineItem<Item>.ID: DiffableOutlineItem<Item>]()
  private var values = [Item]()
  private var childrenByParent = [DiffableOutlineItem<Item>.ID?: [DiffableOutlineItem<Item>]]()
  private var childIndexByID = [DiffableOutlineItem<Item>.ID: Int]()
  private var parentByID = [DiffableOutlineItem<Item>.ID: DiffableOutlineItem<Item>.ID?]()
  private var parentOrder = [DiffableOutlineItem<Item>.ID?]()

}
