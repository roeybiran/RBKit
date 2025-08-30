import CustomDump
import Testing
@testable import RBKit

struct TreeNodeProtocolTests {
  struct MockNode: TreeNodeProtocol, Equatable {
    init(_ title: String, children: [MockNode] = [MockNode]()) {
      self.title = title
      self.children = children
    }

    let title: String
    var children = [MockNode]()

  }

  struct MockNode2: TreeNodeProtocol, Equatable {
    init(_ title: String, children: [MockNode2] = [MockNode2]()) {
      self.title = title
      self.children = children
    }

    let title: String
    var children = [MockNode2]()

  }

  // MARK: - TreeNodeProtocol

  static let testNode = MockNode(
    "1",
    children: [
      MockNode(
        "1.1",
        children: [
          MockNode("1.1.1"),
          MockNode("1.1.2"),
        ]
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
                ]
              ),
              MockNode("1.2.1.2"),
            ]
          ),
          MockNode("1.2.2"),
        ]
      ),
    ]
  )

  static let testNode2 = MockNode2(
    "1",
    children: [
      MockNode2(
        "1.1",
        children: [
          MockNode2("1.1.1"),
          MockNode2("1.1.2"),
        ]
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
                ]
              ),
              MockNode2("1.2.1.2"),
            ]
          ),
          MockNode2("1.2.2"),
        ]
      ),
    ]
  )

  @Test
  func descendants() {
    expectNoDifference(
      Self.testNode.descendants,
      [
        MockNode(
          "1.1",
          children: [
            MockNode("1.1.1"),
            MockNode("1.1.2"),
          ]
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
                  ]
                ),
                MockNode("1.2.1.2"),
              ]
            ),
            MockNode("1.2.2"),
          ]
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
              ]
            ),
            MockNode("1.2.1.2"),
          ]
        ),
        MockNode("1.2.2"),
        MockNode(
          "1.2.1.1",
          children: [
            MockNode("1.2.1.1.1")
          ]
        ),
        MockNode("1.2.1.2"),
        MockNode("1.2.1.1.1"),
      ]
    )
  }

  @Test
  func recursiveFirst_withFound() {
    #expect(Self.testNode.recursiveFirst(where: { $0.title == "1.2.1.2" }) != nil)
  }

  @Test
  func recursiveFirst_withNotFound() {
    #expect(Self.testNode.recursiveFirst(where: { $0.title == "zzzzzzzz" }) == nil)
  }

  @Test
  func recursiveMap() {
    let start = Self.testNode
    let end = Self.testNode2
    expectNoDifference(start.recursiveMap { MockNode2($0.title) }, end)
  }

  @Test
  func recursiveCompactMap() {
    let result = Self.testNode.recursiveCompactMap { node -> MockNode2? in
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
          ]
        ),
        MockNode2(
          "1.2"
        ),
      ]
    )

    expectNoDifference(result, expected)

    // Test when root node transform returns nil
    let nilResult = Self.testNode.recursiveCompactMap { _ -> MockNode2? in
      return nil
    }
    #expect(nilResult == nil)
  }

  @Test
  func subscript_singleMemberArray_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ]
    )
    let b = MockNode("c")
    #expect(a[[1]] == b)
  }

  @Test
  func subscript_singleMemberArray_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ]
    )
    a[[1]] = MockNode("z")
    let b = MockNode("z")
    #expect(a[[1]] == b)
  }

  @Test
  func subscript_array_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode(
          "b",
          children: [
            MockNode("y")
          ]
        ),
        MockNode("c"),
      ]
    )
    #expect(a[[0, 0]] == MockNode("y"))
    #expect(a[[1]] == MockNode("c"))
  }

  @Test
  func subscript_array_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode(
          "c",
          children: [
            MockNode("y")
          ]
        ),
      ]
    )
    a[[1, 0]] = MockNode("z")
    let b = MockNode("z")
    #expect(a[[1, 0]] == b)
  }

  @Test
  func subscript_variadic_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode(
          "b",
          children: [
            MockNode("y")
          ]
        ),
        MockNode("c"),
      ]
    )
    #expect(a[[0, 0]] == MockNode("y"))
  }

  @Test
  func subscript_variadic_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode(
          "c",
          children: [
            MockNode("y")
          ]
        ),
      ]
    )
    a[1, 0] = MockNode("z")
    let b = MockNode("z")
    #expect(a[1, 0] == b)
  }

  @Test
  func array_recursiveMap() {
    let nodes = [
      MockNode("a", children: [MockNode("a.1")]),
      MockNode("b", children: [MockNode("b.1")]),
    ]

    let result = nodes.recursiveMap { MockNode2($0.title) }

    let expected = [
      MockNode2("a", children: [MockNode2("a.1")]),
      MockNode2("b", children: [MockNode2("b.1")]),
    ]

    expectNoDifference(result, expected)
  }

  @Test
  func array_recursiveCompactMap() {
    let nodes = [
      MockNode("a", children: [MockNode("a.1")]),
      MockNode("b", children: [MockNode("b.1")]),
    ]

    let result = nodes.recursiveCompactMap { node -> MockNode2? in
      // Only transform nodes with "a" in their title
      if node.title.contains("a") {
        return MockNode2(node.title)
      }
      return nil
    }

    let expected = [
      MockNode2("a", children: [MockNode2("a.1")])
    ]

    expectNoDifference(result, expected)
  }

  @Test
  func array_recursiveFirst() throws {
    let nodes = [
      MockNode("a", children: [MockNode("a.1")]),
      MockNode("b", children: [MockNode("b.1")]),
    ]

    // Test finding a root node
    let foundRoot = nodes.recursiveFirst(where: { $0.title == "b" })
    #expect(foundRoot?.title == "b")

    // Test finding a child node
    let foundChild = nodes.recursiveFirst(where: { $0.title == "a.1" })
    #expect(foundChild?.title == "a.1")

    // Test not finding a node
    let notFound = nodes.recursiveFirst(where: { $0.title == "c" })
    #expect(notFound == nil)
  }

}
