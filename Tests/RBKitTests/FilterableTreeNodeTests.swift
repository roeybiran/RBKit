import Foundation
import OrderedCollections
import Testing

@testable import RBKit

// MARK: - TestNode

struct TestNode: @MainActor FilterableTreeNode, Equatable {
  var path: [String]
  var matchRanges = [NSRange]()
  var fuzzyRank = 0.0
  var children = [TestNode]()

  var id: String {
    path.last ?? ""
  }

  var title: String {
    path.last ?? ""
  }
}

// MARK: - Test Fixture

// expanded means -> included in the matchingParents property
//
// given:
// ======
// Open
// --Docs
// ----July
// ------July 1 Doc.txt
// ----June
// ------1.txt
// ----May
// ------2.txt
// --Open Quickly
// --Workspace
// Edit
//
// when: search for "Doc" -> "Docs" and "July 1 Doc.txt" matches
// ======================
//
// then:
// =====
// Open -> expanded
// --Docs -> expanded, highlighted
// ----July -> expanded
// ------July 1 Doc.txt -> highlighted
// ----June
// ------1.txt
// ----May
// ------2.txt
//
//
// ***
//
//
// given:
// ======
// Open
// --Docs
// ----July
// ------July 1 Doc.txt
// ----June
// ------1.txt
// ----May
// ------2.txt
// --Open Quickly
// --Workspace
// Edit
//
// when: search for "July 1 Doc.txt" -> "July 1 Doc.txt" matches
// ======================
//
// then:
// =====
// Open -> expanded
// --Docs -> expanded
// ----June -> expanded
// ------July 1 Doc.txt --> highlighted
//
//
// ***
//
// given:
// ======
// Open
// --Docs
// ----July
// ------July 1 Doc.txt
// ----June
// ------1.txt
// ----May
// ------2.txt
// --Open Quickly
// --Workspace
// Edit
//
// when: search for "June" -> "June" matches
// ======================
//
// then:
// =====
// Open -> expanded
// --Docs -> expanded
// ----June -> highlighted
// ------1.txt
//
//

extension TestNode {
  /// Standard test tree: 4 levels, 4 siblings per level
  static let standardTree: [TestNode] = [
    // App1 with full menu structure
    TestNode(
      path: ["App1"],
      children: [
        // File menu
        TestNode(
          path: ["App1", "File"],
          children: [
            // New submenu
            TestNode(
              path: ["App1", "File", "New"],
              children: [
                TestNode(path: ["App1", "File", "New", "Document"]),
                TestNode(path: ["App1", "File", "New", "Folder"]),
                TestNode(path: ["App1", "File", "New", "Project"]),
                TestNode(path: ["App1", "File", "New", "Workspace"]),
              ],
            ),
            // Open submenu
            TestNode(
              path: ["App1", "File", "Open"],
              children: [
                TestNode(path: ["App1", "File", "Open", "File"]),
                TestNode(path: ["App1", "File", "Open", "Folder"]),
                TestNode(path: ["App1", "File", "Open", "Recent"]),
                TestNode(path: ["App1", "File", "Open", "Remote"]),
              ],
            ),
            TestNode(path: ["App1", "File", "Save"]),
            TestNode(path: ["App1", "File", "Close"]),
          ],
        ),
        // Edit menu
        TestNode(
          path: ["App1", "Edit"],
          children: [
            TestNode(path: ["App1", "Edit", "Cut"]),
            TestNode(path: ["App1", "Edit", "Copy"]),
            TestNode(path: ["App1", "Edit", "Paste"]),
            TestNode(path: ["App1", "Edit", "Delete"]),
          ],
        ),
        // View menu
        TestNode(
          path: ["App1", "View"],
          children: [
            // Zoom submenu
            TestNode(
              path: ["App1", "View", "Zoom"],
              children: [
                TestNode(path: ["App1", "View", "Zoom", "In"]),
                TestNode(path: ["App1", "View", "Zoom", "Out"]),
                TestNode(path: ["App1", "View", "Zoom", "Reset"]),
                TestNode(path: ["App1", "View", "Zoom", "Fit"]),
              ],
            ),
            TestNode(path: ["App1", "View", "Layout"]),
            TestNode(path: ["App1", "View", "Theme"]),
            TestNode(path: ["App1", "View", "Sidebar"]),
          ],
        ),
        // Window menu
        TestNode(
          path: ["App1", "Window"],
          children: [
            TestNode(path: ["App1", "Window", "Minimize"]),
            TestNode(path: ["App1", "Window", "Maximize"]),
            TestNode(path: ["App1", "Window", "Fullscreen"]),
            // Split submenu
            TestNode(
              path: ["App1", "Window", "Split"],
              children: [
                TestNode(path: ["App1", "Window", "Split", "Horizontal"]),
                TestNode(path: ["App1", "Window", "Split", "Vertical"]),
                TestNode(path: ["App1", "Window", "Split", "Grid"]),
                TestNode(path: ["App1", "Window", "Split", "Custom"]),
              ],
            ),
          ],
        ),
      ],
    ),
    // App2
    TestNode(
      path: ["App2"],
      children: [
        TestNode(path: ["App2", "File"]),
        TestNode(path: ["App2", "Edit"]),
        TestNode(path: ["App2", "View"]),
        TestNode(path: ["App2", "Window"]),
      ],
    ),
    // App3
    TestNode(
      path: ["App3"],
      children: [
        TestNode(path: ["App3", "File"]),
        TestNode(path: ["App3", "Edit"]),
        TestNode(path: ["App3", "View"]),
        TestNode(path: ["App3", "Window"]),
      ],
    ),
    // App4
    TestNode(
      path: ["App4"],
      children: [
        TestNode(path: ["App4", "File"]),
        TestNode(path: ["App4", "Edit"]),
        TestNode(path: ["App4", "View"]),
        TestNode(path: ["App4", "Window"]),
      ],
    ),
  ]
}

// MARK: - FilterableTreeNodeTests

@Suite(.serialized)

struct FilterableTreeNodeTests {

  @MainActor
  @Test
  func `No matches returns empty result`() {
    let result = filterTreeNode(items: TestNode.standardTree) { _ in
      .init(score: 0.0, ranges: [], matchedTitle: "", itemTitle: "")
    }

    #expect(result.items.isEmpty)
    #expect(result.bestMatch == nil)
    #expect(result.matchingParents.isEmpty)
  }

  @MainActor
  @Test
  func `Match single leaf node at level 4`() {
    let result = filterTreeNode(items: TestNode.standardTree) { item in
      if item.id == "Document" {
        return .init(score: 1.0, ranges: [NSRange(location: 0, length: 3)], matchedTitle: "Document", itemTitle: "Document")
      }
      return .init(score: 0.0, ranges: [], matchedTitle: "", itemTitle: "")
    }

    var tree = TestNode.standardTree
    tree[0].children[0].children[0].children[0].matchRanges = [NSRange(location: 0, length: 3)]
    tree[0].children[0].children[0].children[0].fuzzyRank = 1.0
    tree[0].children[0].children[0].children = [tree[0].children[0].children[0].children[0]]
    tree[0].children[0].children = [tree[0].children[0].children[0]]
    tree[0].children = [tree[0].children[0]]

    #expect(result.items == [tree[0]])
    #expect(result.bestMatch == TestNode.standardTree[0].children[0].children[0].children[0])
    #expect(result.matchingParents == ["App1", "File", "New"])
  }

  @MainActor
  @Test
  func `Match multiple leaves returns all with best match`() {
    let result = filterTreeNode(items: TestNode.standardTree) { item in
      switch item.id {
      case "Document":
        .init(score: 0.8, ranges: [NSRange(location: 0, length: 3)], matchedTitle: "Document", itemTitle: "Document")
      case "In":
        .init(score: 1.0, ranges: [NSRange(location: 0, length: 2)], matchedTitle: "In", itemTitle: "In")
      default:
        .init(score: 0.0, ranges: [], matchedTitle: "", itemTitle: "")
      }
    }

    var tree = TestNode.standardTree
    tree[0].children[0].children[0].children[0].matchRanges = [NSRange(location: 0, length: 3)]
    tree[0].children[0].children[0].children[0].fuzzyRank = 0.8
    tree[0].children[2].children[0].children[0].matchRanges = [NSRange(location: 0, length: 2)]
    tree[0].children[2].children[0].children[0].fuzzyRank = 1.0
    tree[0].children[0].children[0].children = [tree[0].children[0].children[0].children[0]]
    tree[0].children[2].children[0].children = [tree[0].children[2].children[0].children[0]]
    tree[0].children[0].children = [tree[0].children[0].children[0]]
    tree[0].children[2].children = [tree[0].children[2].children[0]]
    tree[0].children = [tree[0].children[0], tree[0].children[2]]

    #expect(result.items == [tree[0]])
    #expect(result.bestMatch == TestNode.standardTree[0].children[2].children[0].children[0])
    #expect(result.matchingParents == ["App1", "File", "New", "View", "Zoom"])
  }

  @MainActor
  @Test
  func `Match parent includes all descendants`() {
    let result = filterTreeNode(items: TestNode.standardTree) { item in
      if item.id == "File", item.path.count == 2 { // "File" menu at level 2
        return .init(score: 1.0, ranges: [NSRange(location: 0, length: 4)], matchedTitle: "File", itemTitle: "File")
      }
      return .init(score: 0.0, ranges: [], matchedTitle: "", itemTitle: "")
    }

    var tree = TestNode.standardTree
    tree[0].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[0].children[0].fuzzyRank = 1.0
    tree[0].children = [tree[0].children[0]]
    tree[1].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[1].children[0].fuzzyRank = 1.0
    tree[1].children = [tree[1].children[0]]
    tree[2].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[2].children[0].fuzzyRank = 1.0
    tree[2].children = [tree[2].children[0]]
    tree[3].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[3].children[0].fuzzyRank = 1.0
    tree[3].children = [tree[3].children[0]]

    #expect(result.items == tree)
    #expect(result.bestMatch == TestNode.standardTree[0].children[0])
    #expect(result.matchingParents == ["App1", "App2", "App3", "App4"])
  }

  @MainActor
  @Test
  func `Match across multiple root nodes`() {
    let result = filterTreeNode(items: TestNode.standardTree) { item in
      // Match "File" in all apps
      if item.title == "File" {
        return .init(score: 1.0, ranges: [NSRange(location: 0, length: 4)], matchedTitle: "File", itemTitle: "File")
      }
      return .init(score: 0.0, ranges: [], matchedTitle: "", itemTitle: "")
    }

    var tree = TestNode.standardTree
    tree[0].children[0].children[1].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[0].children[0].children[1].children[0].fuzzyRank = 1.0
    tree[0].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[0].children[0].fuzzyRank = 1.0
    tree[0].children = [tree[0].children[0]]
    tree[1].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[1].children[0].fuzzyRank = 1.0
    tree[1].children = [tree[1].children[0]]
    tree[2].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[2].children[0].fuzzyRank = 1.0
    tree[2].children = [tree[2].children[0]]
    tree[3].children[0].matchRanges = [NSRange(location: 0, length: 4)]
    tree[3].children[0].fuzzyRank = 1.0
    tree[3].children = [tree[3].children[0]]

    #expect(result.items == tree)
    #expect(result.bestMatch == TestNode.standardTree[0].children[0].children[1].children[0]) // Deepest match wins
    #expect(result.matchingParents == ["App1", "File", "Open", "App2", "App3", "App4"])
  }

  @MainActor
  @Test
  func `Match with contiguous array input, should preserve generic collection type`() {
    let items = ContiguousArray(TestNode.standardTree)

    let result = filterTreeNode(items: items) { item in
      if item.title == "Close" {
        return .init(score: 1.0, ranges: [NSRange(location: 0, length: 5)], matchedTitle: "Close", itemTitle: "Close")
      }
      return .init(score: 0.0, ranges: [], matchedTitle: "", itemTitle: "")
    }

    #expect(type(of: result.items) == ContiguousArray<TestNode>.self)
    #expect(result.bestMatch == TestNode.standardTree[0].children[0].children[3])
    #expect(result.matchingParents == ["App1", "File"])
  }
}
