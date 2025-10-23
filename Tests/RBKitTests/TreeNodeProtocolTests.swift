import Testing

@testable import RBKit

@Suite
struct `TreeNodeProtocol Tests` {
    struct MockNode: TreeNodeProtocol, Equatable {
        init(_ title: String, children: [MockNode] = []) {
            self.title = title
            self.children = children
        }

        let title: String
        var children: [MockNode]
    }

    struct MockNode2: TreeNodeProtocol, Equatable {
        init(_ title: String, children: [MockNode2] = []) {
            self.title = title
            self.children = children
        }

        let title: String
        var children: [MockNode2]
    }

    static let mockTree = MockNode(
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
                                    MockNode("1.2.1.1.1"),
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

    static let mockTree2 = MockNode2(
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
                                    MockNode2("1.2.1.1.1"),
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
    func `descendants, should list nodes depth first`() async throws {
        #expect(
            Self.mockTree.descendants == [
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
                                        MockNode("1.2.1.1.1"),
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
                                MockNode("1.2.1.1.1"),
                            ]
                        ),
                        MockNode("1.2.1.2"),
                    ]
                ),
                MockNode("1.2.2"),
                MockNode(
                    "1.2.1.1",
                    children: [
                        MockNode("1.2.1.1.1"),
                    ]
                ),
                MockNode("1.2.1.2"),
                MockNode("1.2.1.1.1"),
            ]
        )
    }

    @Test
    func `recursiveFirst where:, with matching node, should find it`() async throws {
        #expect(Self.mockTree.recursiveFirst(where: { $0.title == "1.2.1.2" }) != nil)
    }

    @Test
    func `recursiveFirst where:, with no match, should return nil`() async throws {
        #expect(Self.mockTree.recursiveFirst(where: { $0.title == "zzzzzzzz" }) == nil)
    }

    @Test
    func `recursiveMap, should transform hierarchy`() async throws {
        #expect(Self.mockTree.recursiveMap { MockNode2($0.title) } == Self.mockTree2)
    }

    @Test
    func `recursiveCompactMap, with nil results, should skip them`() async throws {
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
                    ]
                ),
                MockNode2(
                    "1.2"
                ),
            ]
        )

        #expect(result == expected)

        let nilResult = Self.mockTree.recursiveCompactMap { _ -> MockNode2? in
            nil
        }
        #expect(nilResult == nil)
    }

    @Test
    func `subscript, with single index, should return child`() async throws {
        let node = MockNode(
            "a",
            children: [
                MockNode("b"),
                MockNode("c"),
            ]
        )

        #expect(node[[1]] == MockNode("c"))
    }

    @Test
    func `subscript, with single index, should update child`() async throws {
        var node = MockNode(
            "a",
            children: [
                MockNode("b"),
                MockNode("c"),
            ]
        )
        node[[1]] = MockNode("z")

        #expect(node[[1]] == MockNode("z"))
    }

    @Test
    func `subscript, with array index, should return nested child`() async throws {
        let node = MockNode(
            "a",
            children: [
                MockNode(
                    "b",
                    children: [
                        MockNode("y"),
                    ]
                ),
                MockNode("c"),
            ]
        )

        #expect(node[[0, 0]] == MockNode("y"))
        #expect(node[[1]] == MockNode("c"))
    }

    @Test
    func `subscript, with array index, should update nested child`() async throws {
        var node = MockNode(
            "a",
            children: [
                MockNode("b"),
                MockNode(
                    "c",
                    children: [
                        MockNode("y"),
                    ]
                ),
            ]
        )
        node[[1, 0]] = MockNode("z")

        #expect(node[[1, 0]] == MockNode("z"))
    }

    @Test
    func `subscript, with variadic indices, should return nested child`() async throws {
        let node = MockNode(
            "a",
            children: [
                MockNode(
                    "b",
                    children: [
                        MockNode("y"),
                    ]
                ),
                MockNode("c"),
            ]
        )

        #expect(node[0, 0] == MockNode("y"))
    }

    @Test
    func `subscript, with variadic indices, should update nested child`() async throws {
        var node = MockNode(
            "a",
            children: [
                MockNode("b"),
                MockNode(
                    "c",
                    children: [
                        MockNode("y"),
                    ]
                ),
            ]
        )
        node[1, 0] = MockNode("z")

        #expect(node[1, 0] == MockNode("z"))
    }

    @Test
    func `recursiveMap, with Array, should transform nodes`() async throws {
        let nodes = [
            MockNode("a", children: [MockNode("a.1")]),
            MockNode("b", children: [MockNode("b.1")]),
        ]

        let result = nodes.recursiveMap { MockNode2($0.title) }

        let expected = [
            MockNode2("a", children: [MockNode2("a.1")]),
            MockNode2("b", children: [MockNode2("b.1")]),
        ]

        #expect(result == expected)
    }

    @Test
    func `recursiveCompactMap, with Array, should filter nodes`() async throws {
        let nodes = [
            MockNode("a", children: [MockNode("a.1")]),
            MockNode("b", children: [MockNode("b.1")]),
        ]

        let result = nodes.recursiveCompactMap { node -> MockNode2? in
            if node.title.contains("a") {
                return MockNode2(node.title)
            }
            return nil
        }

        let expected = [
            MockNode2("a", children: [MockNode2("a.1")]),
        ]

        #expect(result == expected)
    }

    @Test
    func `recursiveFirst where:, with Array, should match nodes`() async throws {
        let nodes = [
            MockNode("a", children: [MockNode("a.1")]),
            MockNode("b", children: [MockNode("b.1")]),
        ]

        let foundRoot = nodes.recursiveFirst(where: { $0.title == "b" })
        #expect(foundRoot?.title == "b")

        let foundChild = nodes.recursiveFirst(where: { $0.title == "a.1" })
        #expect(foundChild?.title == "a.1")

        let notFound = nodes.recursiveFirst(where: { $0.title == "c" })
        #expect(notFound == nil)
    }
}
