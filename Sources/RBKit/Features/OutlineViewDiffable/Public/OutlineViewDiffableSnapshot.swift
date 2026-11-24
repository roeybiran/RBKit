import IssueReporting

public struct OutlineViewDiffableSnapshot<Item: TreeNodeProtocol & Hashable & Sendable> {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  /// Appends `items` after the existing root items.
  ///
  /// Every item in a snapshot must have a unique ID. An item whose ID is already in the snapshot is reported and
  /// left out, along with its children.
  public mutating func append(items: [Item]) {
    typealias ID = DiffableOutlineItem<Item>.ID

    var seenIDs = Set(flattenedTree.keys)
    var duplicateIDs = [ID]()

    func makeOutlineItems(_ items: some Sequence<Item>) -> [DiffableOutlineItem<Item>] {
      var outlineItems = [DiffableOutlineItem<Item>]()
      for item in items {
        if seenIDs.insert(item.id).inserted {
          outlineItems.append(.init(item, children: makeOutlineItems(item.children)))
        } else {
          duplicateIDs.append(item.id)
        }
      }
      return outlineItems
    }

    let originalTree = originalTree + makeOutlineItems(items)

    if !duplicateIDs.isEmpty {
      reportIssue(
        """
        OutlineViewDiffableSnapshot was given items with duplicate IDs, which were left out: \(duplicateIDs)
        """
      )
    }

    var childrenByParent = [ID?: [DiffableOutlineItem<Item>]]()
    var childIndexByID = [ID: Int]()
    var parentOrder = [ID?]()
    var flattenedTree = [ID: DiffableOutlineItem<Item>]()
    var parentByID = [ID: ID?]()

    func append(_ items: [DiffableOutlineItem<Item>], parentID: ID?) {
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
    values.append(contentsOf: items)
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
    guard let item else { return originalTree }
    return outlineItem(for: item)?.children ?? []
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
