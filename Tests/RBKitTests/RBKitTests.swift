import XCTest
import CustomDump
@testable import RBKit

final class Collection_Plus_Tests: XCTestCase {

  // MARK: - CollectionDifferenceChange

  func test_steps() {
    let steps = ["a", "b", "c"].difference(from: ["c", "b", "d"]).inferringMoves().steps
    XCTAssertEqual(
      steps,
      [
        .removed(element: "d", from: 2),
        .moved(element: "c", from: 0, to: 2),
        .inserted(element: "a", at: 0),
      ]
    )
  }

  // MARK: - Collection Extensions

  func test_safe_subscript() {
    let a = [1, 2, 3]
    XCTAssertNil(a[safe: 3])
    XCTAssertNotNil(a[safe: 2])
  }

  func test_isNotEmpty() {
    let a = [1, 2, 3]
    XCTAssertTrue(a.isNotEmpty)
  }

  func test_itemAt() {
    let a = [1, 2, 3]
    XCTAssertEqual(a.item(at: 1), 2)
  }

  func test_itemOptionallyAt() {
    let a = [1, 2, 3]
    XCTAssertEqual(a.item(optionallyAt: 1), 2)
  }

  func test_replaceEmpty() {
    let a = [Int]()
    let b = a.replaceEmpty(with: [0])
    XCTAssertEqual(b, [0])
  }

  func test_replaceEmpty2() {
    let a = [1]
    let b = a.replaceEmpty(with: [0])
    XCTAssertEqual(b, [1])
  }

  func test_replaceEmptyWithOptional() {
    let a = [Int]()
    let b = a.replaceEmpty(with: nil)
    XCTAssertEqual(b, nil)
  }

  func test_replaceEmptyWithOptional2() {
    let a = [1]
    let b = a.replaceEmpty(with: nil)
    XCTAssertEqual(b, [1])
  }

  // MARK: - Key Event Tests

  func test_keyEventInit() {
    let actual = NSEventValue(characters: "a", charactersIgnoringModifiers: "a", keyCode: 0)
    let expected = NSEventValue(
      type: .keyDown,
      modifierFlags: [],
      characters: "a",
      charactersIgnoringModifiers: "a",
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventDownArrow() {
    let actual = NSEventValue.downArrow()
    XCTAssertEqual(actual.keyCode, 125)
    XCTAssertEqual(actual.characters?.count, 1)
    XCTAssertEqual(actual.charactersIgnoringModifiers?.count, 1)
  }

  func test_keyEventUpArrow() {
    let actual = NSEventValue.upArrow()
    XCTAssertEqual(actual.keyCode, 126)
    XCTAssertEqual(actual.characters?.count, 1)
    XCTAssertEqual(actual.charactersIgnoringModifiers?.count, 1)
  }


  // MARK: - TargetAppTests
  
  private class _App: NSRunningApplication {
    override var processIdentifier: pid_t { 0 }
    override var bundleIdentifier: String? { "com.foo.bar" }
    override var localizedName: String? { "Foo" }
    override var bundleURL: URL? { URL(fileURLWithPath: "file://apps/foo") }
  }

  func test_targetApp_init() {
    let app = _App()
    let a = RunningApplication(nsRunningApplication: app)
    let b = RunningApplication(
      isTerminated: app.isTerminated,
      isFinishedLaunching: app.isFinishedLaunching,
      isHidden: app.isHidden,
      isActive: app.isActive,
      ownsMenuBar: app.ownsMenuBar,
      activationPolicy: app.activationPolicy,
      localizedName: app.localizedName,
      bundleIdentifier: app.bundleIdentifier,
      bundleURL: app.bundleURL,
      executableURL: app.executableURL,
      processIdentifier: app.processIdentifier,
      launchDate: app.launchDate,
      executableArchitecture: app.executableArchitecture
    )
    XCTAssertNoDifference(a, b)
  }

  // MARK: - URL Extensions Tests

  func test_appending_queryItems() {
    let actual = URL(fileURLWithPath: "/Users/roey/file.txt").appending(queryItems: [.init(name: "id", value: "foo")])
    let expected = URL(string: "file:///Users/roey/file.txt?id=foo")
    XCTAssertEqual(actual, expected)
  }

  func test__appending_queryItems() {
    let actual = URL(fileURLWithPath: "/Users/roey/file.txt")._appending(queryItems: [.init(name: "id", value: "foo")])
    let expected = URL(string: "file:///Users/roey/file.txt?id=foo")
    XCTAssertEqual(actual, expected)
  }

  func test__directoryHint() {
    XCTAssertEqual(URL._DirectoryHint.isDirectory.directoryHint(), .isDirectory)
    XCTAssertEqual(URL._DirectoryHint.notDirectory.directoryHint(), .notDirectory)
    XCTAssertEqual(URL._DirectoryHint.checkFileSystem.directoryHint(), .checkFileSystem)
    XCTAssertEqual(URL._DirectoryHint.inferFromPath.directoryHint(), .inferFromPath)
  }

  func test_DotSyntaxSettable() {
    let a = NSTextField()
    a.set(\.stringValue, to: "foo")
    XCTAssertEqual(a.stringValue, "foo")
  }

  // MARK: - IdentifiedHash

  func test_identifiedHash() {
    struct IdentifiedHash: IdentityHashable {
      let value: Foo

      init(_ value: Foo) {
        self.value = value
      }
    }
    
    struct Foo: Identifiable {
      let id: String
      let name: String
    }

    let a = IdentifiedHash(Foo(id: "a", name: "a"))
    let a1 = IdentifiedHash(Foo(id: "a", name: "a1"))
    let b = IdentifiedHash(Foo(id: "b", name: "b"))

    XCTAssertEqual(a.name, "a")
    XCTAssertEqual(a, a1)
    XCTAssertEqual(a.hashValue, a1.hashValue)
    XCTAssertEqual(a.hashValue, a.id.hashValue)
    XCTAssertNotEqual(a, b)
  }

  // MARK: - TreeNodeProtocol

  static let testNode = Node("1", children: [
    Node("1.1", children: [
      Node("1.1.1"),
      Node("1.1.2")
    ]),
    Node("1.2", children: [
      Node("1.2.1", children: [
        Node("1.2.1.1", children: [
          Node("1.2.1.1.1")
        ]),
        Node("1.2.1.2")
      ]),
      Node("1.2.2")
    ])
  ])

  static let testNode2 = Node2("1", children: [
    Node2("1.1", children: [
      Node2("1.1.1"),
      Node2("1.1.2")
    ]),
    Node2("1.2", children: [
      Node2("1.2.1", children: [
        Node2("1.2.1.1", children: [
          Node2("1.2.1.1.1")
        ]),
        Node2("1.2.1.2")
      ]),
      Node2("1.2.2")
    ])
  ])

  struct Node: TreeNodeProtocol, Equatable {
    let title: String
    var children = [Node]()

    init(_ title: String, children: [Node] = [Node]()) {
      self.title = title
      self.children = children
    }
  }

  struct Node2: TreeNodeProtocol, Equatable {
    let title: String
    var children = [Node2]()

    init(_ title: String, children: [Node2] = [Node2]()) {
      self.title = title
      self.children = children
    }
  }

  func test_descendants() {
    XCTAssertNoDifference(
      Self.testNode.descendants,
      [
        Node("1.1", children: [
          Node("1.1.1"),
          Node("1.1.2")
        ]),
        Node("1.2", children: [
          Node("1.2.1", children: [
            Node("1.2.1.1", children: [
              Node("1.2.1.1.1")
            ]),
            Node("1.2.1.2")
          ]),
          Node("1.2.2")
        ]),
        Node("1.1.1"),
        Node("1.1.2"),
        Node("1.2.1", children: [
          Node("1.2.1.1", children: [
            Node("1.2.1.1.1")
          ]),
          Node("1.2.1.2")
        ]),
        Node("1.2.2"),
        Node("1.2.1.1", children: [
          Node("1.2.1.1.1")
        ]),
        Node("1.2.1.2"),
        Node("1.2.1.1.1")
      ]
    )
  }

  func test_firstNode() {
    XCTAssertNotNil(Self.testNode.firstNode(where: { $0.title == "1.2.1.2"} ))
    XCTAssertNil(Self.testNode.firstNode(where: { $0.title == "zzzzzzzz"} ))
  }

  func test_map() {
    XCTAssertNoDifference(
      Self.testNode.map { Node2($0.title) },
      Self.testNode2
    )
  }

  // MARK: -

  func test_enumerateSubviews() {
    let a = NSView()
    let b = NSView()
    let c = NSView()
    let d = NSView()
    let e = NSView()
    a.addSubview(b)
    b.addSubview(c)
    b.addSubview(d)
    d.addSubview(e)

    var count = 0
    a.enumerateSubviews(using: { view in
      view.identifier = "a"
      count += 1
    })

    XCTAssertEqual(count, 4)
    XCTAssertEqual(a.subviews[0].identifier, "a")
  }

  func test_dotSyntaxSettable() {
    let view = NSView()
    XCTAssertEqual(view.identifier, nil)
    view.set(\.identifier, to: "foo")
    XCTAssertEqual(view.identifier, "foo")
  }

  func test_dictionary() {
    let dict = ["a": 0]
    XCTAssertEqual(dict[Optional("a")], 0)
    XCTAssertEqual(dict[nil], nil)
  }

  func test_dictionary2() {
    let dict = ["a": [0]]
    XCTAssertEqual(dict[Optional("a")], [0])
    XCTAssertEqual(dict[nil], [])
  }

  func test_dictionary3() {
    let dict = ["a": [0]]
    XCTAssertEqual(dict[Optional("b")], [])
  }
}
