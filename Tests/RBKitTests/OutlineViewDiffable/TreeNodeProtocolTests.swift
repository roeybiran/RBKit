import CustomDump
import IdentifiedCollections
import Testing

@testable import RBKit

struct TreeNodeProtocolTests {
  struct MockNode: TreeNodeProtocol, Equatable {
    init(_ title: String, children: [MockNode] = []) {
      self.title = title
      self.children = children
    }

    let title: String
    var children: [MockNode]

    var id: String {
      title
    }
  }

  struct MockNode2: TreeNodeProtocol, Equatable {
    init(_ title: String, children: [MockNode2] = []) {
      self.title = title
      self.children = .init(uniqueElements: children)
    }

    let title: String
    var children: IdentifiedArrayOf<MockNode2>

    var id: String {
      title
    }
  }

  static let mockTree = MockNode(
    "1",
    children: [
      MockNode(
        "1.1",
        children: [
          MockNode("1.1.1"),
          MockNode("1.1.2"),
        ],
      ),
      MockNode(
        "1.2",
        children: [
          MockNode(
            "1.2.1",
            children: [
              MockNode(
                "1.2.1.1",
                children: [
                  MockNode("1.2.1.1.1")
                ],
              ),
              MockNode("1.2.1.2"),
            ],
          ),
          MockNode("1.2.2"),
        ],
      ),
    ],
  )

  static let mockTree2 = MockNode2(
    "1",
    children: [
      MockNode2(
        "1.1",
        children: [
          MockNode2("1.1.1"),
          MockNode2("1.1.2"),
        ],
      ),
      MockNode2(
        "1.2",
        children: [
          MockNode2(
            "1.2.1",
            children: [
              MockNode2(
                "1.2.1.1",
                children: [
                  MockNode2("1.2.1.1.1")
                ],
              ),
              MockNode2("1.2.1.2"),
            ],
          ),
          MockNode2("1.2.2"),
        ],
      ),
    ],
  )

  @Test
  func `descendants, should list nodes depth first`() {
    #expect(
      Self.mockTree.descendants == [
        MockNode(
          "1.1",
          children: [
            MockNode("1.1.1"),
            MockNode("1.1.2"),
          ],
        ),
        MockNode(
          "1.2",
          children: [
            MockNode(
              "1.2.1",
              children: [
                MockNode(
                  "1.2.1.1",
                  children: [
                    MockNode("1.2.1.1.1")
                  ],
                ),
                MockNode("1.2.1.2"),
              ],
            ),
            MockNode("1.2.2"),
          ],
        ),
        MockNode("1.1.1"),
        MockNode("1.1.2"),
        MockNode(
          "1.2.1",
          children: [
            MockNode(
              "1.2.1.1",
              children: [
                MockNode("1.2.1.1.1")
              ],
            ),
            MockNode("1.2.1.2"),
          ],
        ),
        MockNode("1.2.2"),
        MockNode(
          "1.2.1.1",
          children: [
            MockNode("1.2.1.1.1")
          ],
        ),
        MockNode("1.2.1.2"),
        MockNode("1.2.1.1.1"),
      ]
    )
  }

  @Test
  func `recursiveFirst where:, with matching node, should find it`() {
    #expect(Self.mockTree.recursiveFirst(where: { $0.title == "1.2.1.2" }) != nil)
  }

  @Test
  func `recursiveFirst where:, with no match, should return nil`() {
    #expect(Self.mockTree.recursiveFirst(where: { $0.title == "zzzzzzzz" }) == nil)
  }

  @Test
  func `recursiveFirst where:, with root match, should return self`() {
    expectNoDifference(Self.mockTree.recursiveFirst(where: { $0.title == "1" }), Self.mockTree)
  }

  @Test
  func `recursiveMap, should transform hierarchy`() {
    #expect(Self.mockTree.recursiveMap { MockNode2($0.title) } == Self.mockTree2)
  }

  @Test
  func `recursiveCompactMap, with nil results, should skip them`() {
    let result = Self.mockTree.recursiveCompactMap { node -> MockNode2? in
      if node.title == "1" || node.title.starts(with: "1.1") || node.title == "1.2" {
        return MockNode2(node.title)
      }
      return nil
    }

    let expected = MockNode2(
      "1",
      children: [
        MockNode2(
          "1.1",
          children: [
            MockNode2("1.1.1"),
            MockNode2("1.1.2"),
          ],
        ),
        MockNode2(
          "1.2"
        ),
      ],
    )

    #expect(result == expected)

    let nilResult = Self.mockTree.recursiveCompactMap { _ -> MockNode2? in
      nil
    }
    #expect(nilResult == nil)
  }

  @Test
  func `Collection.recursiveMap, should transform each root hierarchy`() {
    let forest = [
      Self.mockTree,
      MockNode(
        "2",
        children: [
          MockNode("2.1")
        ],
      ),
    ]

    expectNoDifference(
      forest.recursiveMap { MockNode2($0.title) },
      [
        Self.mockTree2,
        MockNode2(
          "2",
          children: [
            MockNode2("2.1")
          ],
        ),
      ],
    )
  }

  @Test
  func `Collection.recursiveCompactMap, with nil root results, should skip them`() {
    let forest = [
      Self.mockTree,
      MockNode(
        "2",
        children: [
          MockNode("2.1")
        ],
      ),
    ]

    expectNoDifference(
      forest.recursiveCompactMap { node in
        guard node.title.hasPrefix("1") else { return nil }
        return MockNode2(node.title)
      },
      [Self.mockTree2],
    )
  }

  @Test
  func `Collection.recursiveFirst where:, with nested match, should find it`() {
    let forest = [
      MockNode("0"),
      Self.mockTree,
    ]

    expectNoDifference(
      forest.recursiveFirst(where: { $0.title == "1.2.1.1.1" }),
      MockNode("1.2.1.1.1"),
    )
  }

  @Test
  func `subscript, with single index, should return child`() {
    let node = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ],
    )

    #expect(node[[1]] == MockNode("c"))
  }

  @Test
  func `subscript, with single index, should update child`() {
    var node = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ],
    )
    node[[1]] = MockNode("z")

    #expect(node[[1]] == MockNode("z"))
  }

  @Test
  func `subscript, with empty indices, should return self`() {
    expectNoDifference(Self.mockTree[[]], Self.mockTree)
  }

  @Test
  func `subscript, with empty indices, should replace self`() {
    var node = Self.mockTree
    node[[]] = MockNode("z")

    expectNoDifference(node, MockNode("z"))
  }

  @Test
  func `subscript, with variadic indices, should return nested child`() {
    expectNoDifference(Self.mockTree[1, 0, 0, 0], MockNode("1.2.1.1.1"))
  }

  @Test
  func `subscript, with variadic indices, should update nested child`() {
    var node = Self.mockTree
    node[1, 0, 1] = MockNode("changed")

    expectNoDifference(node[1, 0, 1], MockNode("changed"))
  }
}
