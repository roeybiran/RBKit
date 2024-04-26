import XCTest
import CustomDump
import Carbon
@testable import RBKit

final class RBKitTests: XCTestCase {

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

  // MARK: - NSEventValue

  func test_keyEventInitFromNSEvent_withKeyDown_shouldCreateEvent() {
    let actual = NSEventValue(
      nsEvent: NSEvent.keyEvent(
        with: .keyDown,
        location: .zero,
        modifierFlags: [],
        timestamp: .zero,
        windowNumber: .zero,
        context: nil,
        characters: NSEvent.SpecialKey.downArrow.character,
        charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
        isARepeat: false,
        keyCode: UInt16(126)
      )!
    )
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(126),
      specialKey: .downArrow,
      isARepeat: false
    )

    XCTAssertNoDifference(actual, expected)
  }

  func test_keyEventInitFromNSEvent_withKeyUp_shouldCreateEvent() {
    let actual = NSEventValue(
      nsEvent: NSEvent.keyEvent(
        with: .keyUp,
        location: .zero,
        modifierFlags: .command,
        timestamp: .zero,
        windowNumber: .zero,
        context: nil,
        characters: NSEvent.SpecialKey.downArrow.character,
        charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
        isARepeat: false,
        keyCode: UInt16(126)
      )!
    )
    let expected = NSEventValue(
      type: .keyUp,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: .command,
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(126),
      specialKey: .downArrow,
      isARepeat: false
    )

    XCTAssertNoDifference(actual, expected)
  }

  func test_keyEventInitFromNSEvent_withNonKeyEvent_shouldBeNil() {
    let actual = NSEventValue(
      nsEvent: NSEvent.keyEvent(
        with: .flagsChanged,
        location: .zero,
        modifierFlags: .command,
        timestamp: .zero,
        windowNumber: .zero,
        context: nil,
        characters: NSEvent.SpecialKey.downArrow.character,
        charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
        isARepeat: false,
        keyCode: UInt16(126)
      )!
    )
    XCTAssertNoDifference(actual, nil)
  }

  func test_keyEventUpArrow() {
    let actual = NSEventValue.upArrow()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.upArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.upArrow.character,
      keyCode: UInt16(126),
      specialKey: .upArrow,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventRightArrow() {
    let actual = NSEventValue.rightArrow()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.rightArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.rightArrow.character,
      keyCode: UInt16(124),
      specialKey: .rightArrow,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventDownArrow() {
    let actual = NSEventValue.downArrow()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(125),
      specialKey: .downArrow,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventLeftArrow() {
    let actual = NSEventValue.leftArrow()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.leftArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.leftArrow.character,
      keyCode: UInt16(123),
      specialKey: .leftArrow,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventPageUp() {
    let actual = NSEventValue.pageUp()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: .init(rawValue: 0x800100),
      characters: NSEvent.SpecialKey.pageUp.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageUp.character,
      keyCode: UInt16(116),
      specialKey: .pageUp,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventPageDown() {
    let actual = NSEventValue.pageDown()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: .init(rawValue: 0x800100),
      characters: NSEvent.SpecialKey.pageDown.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageDown.character,
      keyCode: UInt16(121),
      specialKey: .pageDown,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventHome() {
    let actual = NSEventValue.home()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.home.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.home.character,
      keyCode: UInt16(115),
      specialKey: .home,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventEnd() {
    let actual = NSEventValue.end()
    let expected = NSEventValue(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: [],
      characters: NSEvent.SpecialKey.end.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.end.character,
      keyCode: UInt16(119),
      specialKey: .end,
      isARepeat: false
    )
    XCTAssertEqual(actual, expected)
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

  static let testNode = MockNode("1", children: [
    MockNode("1.1", children: [
      MockNode("1.1.1"),
      MockNode("1.1.2")
    ]),
    MockNode("1.2", children: [
      MockNode("1.2.1", children: [
        MockNode("1.2.1.1", children: [
          MockNode("1.2.1.1.1")
        ]),
        MockNode("1.2.1.2")
      ]),
      MockNode("1.2.2")
    ])
  ])

  static let testNode2 = MockNode2("1", children: [
    MockNode2("1.1", children: [
      MockNode2("1.1.1"),
      MockNode2("1.1.2")
    ]),
    MockNode2("1.2", children: [
      MockNode2("1.2.1", children: [
        MockNode2("1.2.1.1", children: [
          MockNode2("1.2.1.1.1")
        ]),
        MockNode2("1.2.1.2")
      ]),
      MockNode2("1.2.2")
    ])
  ])

  struct MockNode: TreeNodeProtocol, Equatable {
    let title: String
    var children = [MockNode]()

    init(_ title: String, children: [MockNode] = [MockNode]()) {
      self.title = title
      self.children = children
    }
  }

  struct MockNode2: TreeNodeProtocol, Equatable {
    let title: String
    var children = [MockNode2]()

    init(_ title: String, children: [MockNode2] = [MockNode2]()) {
      self.title = title
      self.children = children
    }
  }

  func test_descendants() {
    XCTAssertNoDifference(
      Self.testNode.descendants,
      [
        MockNode("1.1", children: [
          MockNode("1.1.1"),
          MockNode("1.1.2")
        ]),
        MockNode("1.2", children: [
          MockNode("1.2.1", children: [
            MockNode("1.2.1.1", children: [
              MockNode("1.2.1.1.1")
            ]),
            MockNode("1.2.1.2")
          ]),
          MockNode("1.2.2")
        ]),
        MockNode("1.1.1"),
        MockNode("1.1.2"),
        MockNode("1.2.1", children: [
          MockNode("1.2.1.1", children: [
            MockNode("1.2.1.1.1")
          ]),
          MockNode("1.2.1.2")
        ]),
        MockNode("1.2.2"),
        MockNode("1.2.1.1", children: [
          MockNode("1.2.1.1.1")
        ]),
        MockNode("1.2.1.2"),
        MockNode("1.2.1.1.1")
      ]
    )
  }

  func test_firstNode() {
    XCTAssertNotNil(Self.testNode.first(where: { $0.title == "1.2.1.2"} ))
    XCTAssertNil(Self.testNode.first(where: { $0.title == "zzzzzzzz"} ))
  }

  func test_map() {
    XCTAssertNoDifference(
      Self.testNode.map { MockNode2($0.title) },
      Self.testNode2
    )
  }

  func test_subscript_singleMemberArray_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ])
    let b = MockNode("c")
    XCTAssertEqual(a[[1]], b)
  }

  func test_subscript_singleMemberArray_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ])
    a[[1]] = MockNode("z")
    let b = MockNode("z")
    XCTAssertEqual(a[[1]], b)
  }

  func test_subscript_array_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode(
          "b",
          children: [
            MockNode("y"),
          ]),
        MockNode("c"),
      ])
    XCTAssertEqual(a[[0, 0]], MockNode("y"))
    XCTAssertEqual(a[[1]], MockNode("c"))
  }

  func test_subscript_array_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode(
          "c",
          children: [
            MockNode("y"),
          ]),
      ])
    a[[1, 0]] = MockNode("z")
    let b = MockNode("z")
    XCTAssertEqual(a[[1, 0]], b)
  }

  func test_subscript_variadic_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode(
          "b",
          children: [
            MockNode("y"),
          ]),
        MockNode("c"),
      ])
    XCTAssertEqual(a[[0, 0]], MockNode("y"))
  }

  func test_subscript_variadic_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode(
          "c",
          children: [
            MockNode("y"),
          ]),
      ])
    a[1, 0] = MockNode("z")
    let b = MockNode("z")
    XCTAssertEqual(a[1, 0], b)
  }

  // MARK: - NSView+

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

  // MARK: - Sequence extensions

  func test_sortByKeyPath() {
    struct Foo: Equatable {
      let id: Int
      let kind: String
    }
    let a = [Foo(id: 1, kind: "Book"), Foo(id: 0, kind: "Library")]
    let b = a.sorted(by: \.id)
    XCTAssertEqual(b, a.reversed())
  }

  func test_grouping() {
    struct Foo: Equatable {
      let name: String
      let kind: String
    }
    let a = [Foo(name: "a", kind: "Book"), Foo(name: "b", kind: "Library")]
    let b = a.dictionary(groupingBy: { $0.kind })
    XCTAssertEqual(b, [
      "Book": [a[0]],
      "Library": [a[1]],
    ])
  }

  func test_toArray() {
    let a = Set<String>()
    let b = [String]()
    XCTAssertEqual(a.toArray(), b)
  }

  func test_toSet() {
    let a = ["a", "a"]
    let b = Set(["a"])
    XCTAssertEqual(a.toSet(), b)
  }

  // MARK: - Dictionary extensions

  func test_dictionary() {
    let dict = ["a": 0]
    let key: String? = "a"
    XCTAssertEqual(dict[key], 0)
    XCTAssertEqual(dict[nil], nil)
  }

  func test_dictionary2() {
    let dict = ["a": [0]]
    let key: String? = "a"
    XCTAssertEqual(dict[key, default: [0]], [0])
  }

  func test_dictionary3() {
    let dict = ["b": [0]]
    let key: String? = "a"
    XCTAssertEqual(dict[key, default: [0]], [0])
  }

  func test_dictionary4() {
    let dict = ["a": [0]]
    let key: String? = nil
    XCTAssertEqual(dict[key, default: [0]], [0])
  }

  // MARK: - Array tests

  func test_concat() {
    let a = ["a"].concat(["b"])
    XCTAssertEqual(a, ["a", "b"])

    let b = ["a"].concat("b")
    XCTAssertEqual(b, ["a", "b"])
  }

  func test_lastIndex() {
    XCTAssertEqual(["a"].lastIndex, 0)
    XCTAssertEqual(["a", "b"].lastIndex, 1)
    XCTAssertEqual([].lastIndex, 0)
  }

  // MARK: -

  func test_clamp() {
    XCTAssertEqual(clamp(min: 2, ideal: 999, max: 10), 10)
    XCTAssertEqual(clamp(min: 2, ideal: 5, max: 10), 5)
  }

  // MARK: - Cocoa

  func test_makeCell() {
    let tv = NSTableView()
    let cell1 = tv.makeCell(withIdentifier: "foo", owner: self) as NSTableCellView
    XCTAssertEqual(cell1.identifier, "foo")

    let cell2 = tv.makeCell() as NSTableCellView
    XCTAssertEqual(cell2.identifier, "\(NSTableCellView.self)")
  }

  // MARK: - Quartz Core

  func test_cornerMasks() {
    XCTAssertEqual(CACornerMask.topLeft, .layerMinXMaxYCorner)
    XCTAssertEqual(CACornerMask.topRight, .layerMaxXMaxYCorner)
    XCTAssertEqual(CACornerMask.bottomRight, .layerMaxXMinYCorner)
    XCTAssertEqual(CACornerMask.bottomLeft, .layerMinXMinYCorner)
    XCTAssertEqual(CACornerMask.all, [.topLeft, .topRight, .bottomLeft, .bottomRight])
  }

  // MARK: -

  func test_NSObjectUIIdentifier() {
    XCTAssertEqual(NSObject.userInterfaceIdentifier, "NSObject")
    XCTAssertEqual(NSView.userInterfaceIdentifier, "NSView")

    class MainCell: NSTableCellView {}

    XCTAssertEqual(MainCell.userInterfaceIdentifier, "MainCell")
  }

  // MARK: - NSEvent.ModifierFlags

  func test_NSEventModifierFlags_initWithCarbon() throws {
    XCTAssertEqual(NSEvent.ModifierFlags(carbon: cmdKey), .command)

    var mods = 0
    mods |= cmdKey
    mods |= shiftKey
    mods |= controlKey
    mods |= optionKey
    XCTAssertEqual(NSEvent.ModifierFlags(carbon: mods), [.command, .shift, .control, .option])
  }

  func test_carbonized() throws {
    var mods = 0
    mods |= cmdKey
    mods |= shiftKey
    mods |= controlKey
    mods |= optionKey
    XCTAssertEqual(NSEvent.ModifierFlags([.command, .shift, .control, .option]).carbonized, mods)
  }

  func test_hotKeyApplicable() throws {
    let a = NSEvent.ModifierFlags([.command, .shift, .control, .option, .function, .capsLock, .numericPad])
    XCTAssertEqual(a.hotkeyApplicable, [.command, .shift, .control, .option])
  }

  func test_description() throws {
    let a = NSEvent.ModifierFlags([.command, .shift, .control, .option].shuffled())
    XCTAssertEqual("\(a)", "⌃⌥⇧⌘")
  }
}
