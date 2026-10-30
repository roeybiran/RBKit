import Foundation
import OrderedCollections

// MARK: - FilterableTreeNode

public protocol FilterableTreeNode: Identifiable where ID: Hashable {
  associatedtype Children: RangeReplaceableCollection = [Self] where Children.Element == Self

  var children: Children { get set }
  var matchRanges: [NSRange] { get set }
  var fuzzyRank: Double { get set }
}

// MARK: - FilterResult

/// https://github.com/microsoft/vscode/blob/dead67fe6ac8d786558c1fd83ee6d0f7a43ec269/src/vs/base/browser/ui/tree/indexTreeModel.ts#L589
/// 1. If a non-leaf item matches, include it and the entire hierarchy beneath.
/// 1.1. The item should be collapsed (unless it has matching descendants).
/// 2. If a leaf item matches, include every ancestor (without its siblings, unless they match too).
/// 2.1. Each ancestor should be expanded.
public struct FilterResult<Node: FilterableTreeNode & Equatable, Items: RangeReplaceableCollection>
  where Items.Element == Node
{
  public var items = Items()
  public var bestMatch: Node?
  public var matchingParents: OrderedSet<Node.ID> = []

  fileprivate var parentRangesToApply = [NSRange]()
}

// MARK: - MatchResult

public struct MatchResult {
  public init(score: Double, ranges: [NSRange], matchedTitle: String, itemTitle: String) {
    self.score = score
    self.ranges = ranges
    self.matchedTitle = matchedTitle
    self.itemTitle = itemTitle
  }

  public let score: Double
  public let ranges: [NSRange]
  public let matchedTitle: String
  public let itemTitle: String

}

public func filterTreeNode<Items: RangeReplaceableCollection>(
  items: Items,
  matcher: @escaping (Items.Element) -> MatchResult,
) -> FilterResult<Items.Element, Items>
  where Items.Element: FilterableTreeNode & Equatable
{
  typealias Node = Items.Element

  var matchingParents = OrderedSet<Node.ID>()
  var bestMatch: (Node, Double)?

  func filter<CurrentItems: RangeReplaceableCollection>(
    items: CurrentItems,
    parentMatches: Bool = false,
    ancestors: [Node.ID] = [],
  ) -> FilterResult<Node, CurrentItems>
    where CurrentItems.Element == Node
  {
    var filteredItems = CurrentItems()
    var parentRangesToApply = [NSRange]()

    for item in items {
      let match = matcher(item)
      let itemMatches = match.score > 0

      let childResult = filter(
        items: item.children,
        parentMatches: itemMatches || parentMatches,
        ancestors: ancestors + [item.id],
      )

      if itemMatches {
        matchingParents.formUnion(ancestors)
      }

      if match.score > bestMatch?.1 ?? 0 {
        bestMatch = (item, match.score)
      }

      var parentRangesToBubbleUp = [NSRange]()

      if itemMatches || parentMatches || !childResult.items.isEmpty {
        var resultItem = item
        resultItem.children = childResult.items
        resultItem.fuzzyRank = match.score

        // Split match ranges: child portion for this item, parent portion to bubble up
        var childRanges: [NSRange]
        var parentRanges: [NSRange]

        // Check if matched title differs from item title (indicates nested item with contextual title)
        if match.matchedTitle != match.itemTitle {
          // For nested items, matchedTitle is "Parent › Child", itemTitle is "Child"
          // We need to find where itemTitle starts in matchedTitle
          if let childStart = match.matchedTitle.range(of: match.itemTitle, options: .backwards)?.lowerBound {
            let childOffset = match.matchedTitle.distance(from: match.matchedTitle.startIndex, to: childStart)

            var tempChildRanges = [NSRange]()
            var tempParentRanges = [NSRange]()

            for range in match.ranges {
              let rangeStart = range.location
              let rangeEnd = range.location + range.length

              // Check if range overlaps with child portion
              if rangeEnd <= childOffset {
                // Range is entirely in parent portion
                tempParentRanges.append(range)
              } else if rangeStart >= childOffset {
                // Range is entirely in child portion, adjust offset to be relative to child
                tempChildRanges.append(NSRange(location: rangeStart - childOffset, length: range.length))
              } else {
                // Range spans both parent and child portions - split it into two ranges
                let parentPortion = NSRange(location: rangeStart, length: childOffset - rangeStart)
                let childPortion = NSRange(location: 0, length: rangeEnd - childOffset)
                tempParentRanges.append(parentPortion)
                tempChildRanges.append(childPortion)
              }
            }

            childRanges = tempChildRanges
            parentRanges = tempParentRanges
          } else {
            childRanges = []
            parentRanges = []
          }
        } else {
          // Non-nested items: matchedTitle == itemTitle, no adjustment needed
          childRanges = match.ranges
          parentRanges = []
        }

        resultItem.matchRanges = childRanges

        // Bubble up parent ranges from this item's match
        parentRangesToBubbleUp.append(contentsOf: parentRanges)

        // Apply parent ranges from children to this item (their immediate parent)
        resultItem.matchRanges.append(contentsOf: childResult.parentRangesToApply)

        filteredItems.append(resultItem)
      } else {
        // Item not included, but still bubble up parent ranges from children
        parentRangesToBubbleUp.append(contentsOf: childResult.parentRangesToApply)
      }

      parentRangesToApply.append(contentsOf: parentRangesToBubbleUp)
    }

    return .init(
      items: filteredItems,
      parentRangesToApply: parentRangesToApply,
    )
  }

  var res = filter(items: items)
  res.matchingParents = matchingParents
  res.bestMatch = bestMatch?.0
  return res
}
