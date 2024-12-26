import AppKit
import Carbon
import CustomDump
import Testing

@testable import RBKit

// MARK: - NSApplication.ActivationPolicy + Codable

extension NSApplication.ActivationPolicy: Codable { }

// MARK: - RBKitTests

@MainActor
struct RBKitTests {

  // MARK: Internal

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

  // MARK: - TreeNodeProtocol

  static let testNode = MockNode(
    "1",
    children: [
      MockNode(
        "1.1",
        children: [
          MockNode("1.1.1"),
          MockNode("1.1.2"),
        ]),
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
                ]),
              MockNode("1.2.1.2"),
            ]),
          MockNode("1.2.2"),
        ]),
    ])

  static let testNode2 = MockNode2(
    "1",
    children: [
      MockNode2(
        "1.1",
        children: [
          MockNode2("1.1.1"),
          MockNode2("1.1.2"),
        ]),
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
                ]),
              MockNode2("1.2.1.2"),
            ]),
          MockNode2("1.2.2"),
        ]),
    ])

  // MARK: - Collection Extensions

  @Test
  func test_safe_subscript() {
    let a = [1, 2, 3]
    #expect(a[safe: 3] == nil)
    #expect(a[safe: 2] != nil)
  }

  @Test
  func test_isNotEmpty() {
    let a = [1, 2, 3]
    #expect(a.isNotEmpty)
  }

  @Test
  func test_itemAt() {
    let a = [1, 2, 3]
    #expect(a.item(at: 1) == 2)
  }

  @Test
  func test_itemOptionallyAt() {
    let a = [1, 2, 3]
    #expect(a.item(optionallyAt: 1) == 2)
  }

  @Test
  func test_replaceEmpty() {
    let a = [Int]()
    let b = a.replaceEmpty(with: [0])
    #expect(b == [0])
  }

  @Test
  func test_replaceEmpty2() {
    let a = [1]
    let b = a.replaceEmpty(with: [0])
    #expect(b == [1])
  }

  @Test
  func test_replaceEmptyWithOptional() {
    let a = [Int]()
    let b = a.replaceEmpty(with: nil)
    #expect(b == nil)
  }

  @Test
  func test_replaceEmptyWithOptional2() {
    let a = [1]
    let b = a.replaceEmpty(with: nil)
    #expect(b == [1])
  }

  // MARK: - NSEventValue

  @Test
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
        keyCode: UInt16(126))!)
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
      isARepeat: false)

    expectNoDifference(actual, expected)
  }

  @Test
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
        keyCode: UInt16(126))!)
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
      isARepeat: false)

    expectNoDifference(actual, expected)
  }

  @Test
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
        keyCode: UInt16(126))!)
    expectNoDifference(actual, nil)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
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
      isARepeat: false)
    #expect(actual == expected)
  }

  @Test
  func test_targetApp_init() {
    struct RunningApp: RunningApplicationProtocol {
      var isTerminated: Bool

      var isFinishedLaunching: Bool

      var isHidden: Bool

      var isActive: Bool

      var ownsMenuBar: Bool

      var activationPolicy: NSApplication.ActivationPolicy

      var localizedName: String?

      var bundleIdentifier: String?

      var bundleURL: URL?

      var executableURL: URL?

      var processIdentifier: pid_t

      var launchDate: Date?

      var executableArchitecture: Int
    }
    let app = _App()
    let a = RunningApp(nsRunningApplication: app)
    let b = RunningApp(
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
      executableArchitecture: app.executableArchitecture)
    expectNoDifference(a, b)
  }

  // MARK: - URL Extensions Tests

  @Test
  func test_appending_queryItems() {
    let actual = URL(fileURLWithPath: "/Users/roey/file.txt").appending(queryItems: [
      .init(name: "id", value: "foo"),
    ])
    let expected = URL(string: "file:///Users/roey/file.txt?id=foo")
    #expect(actual == expected)
  }

  @Test
  func test__appending_queryItems() {
    let actual = URL(fileURLWithPath: "/Users/roey/file.txt").backported_appending(queryItems: [
      .init(name: "id", value: "foo"),
    ])
    let expected = URL(string: "file:///Users/roey/file.txt?id=foo")
    #expect(actual == expected)
  }

  @Test
  func test__directoryHint() {
    #expect(URL.BackportedDirectoryHint.isDirectory.directoryHint() == .isDirectory)
    #expect(URL.BackportedDirectoryHint.notDirectory.directoryHint() == .notDirectory)
    #expect(URL.BackportedDirectoryHint.checkFileSystem.directoryHint() == .checkFileSystem)
    #expect(URL.BackportedDirectoryHint.inferFromPath.directoryHint() == .inferFromPath)
  }

  @Test
  func test_DotSyntaxSettable() {
    let a = NSTextField()
    a.set(\.stringValue, to: "foo")
    #expect(a.stringValue == "foo")
  }

  // MARK: - IdentifiedHash

  @Test
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

    #expect(a.name == "a")
    #expect(a == a1)
    #expect(a.hashValue == a1.hashValue)
    #expect(a.hashValue == a.id.hashValue)
    #expect(a != b)
  }

  @Test
  func test_descendants() {
    expectNoDifference(
      Self.testNode.descendants,
      [
        MockNode(
          "1.1",
          children: [
            MockNode("1.1.1"),
            MockNode("1.1.2"),
          ]),
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
                  ]),
                MockNode("1.2.1.2"),
              ]),
            MockNode("1.2.2"),
          ]),
        MockNode("1.1.1"),
        MockNode("1.1.2"),
        MockNode(
          "1.2.1",
          children: [
            MockNode(
              "1.2.1.1",
              children: [
                MockNode("1.2.1.1.1"),
              ]),
            MockNode("1.2.1.2"),
          ]),
        MockNode("1.2.2"),
        MockNode(
          "1.2.1.1",
          children: [
            MockNode("1.2.1.1.1"),
          ]),
        MockNode("1.2.1.2"),
        MockNode("1.2.1.1.1"),
      ])
  }

  @Test
  func test_firstNode() {
    #expect(Self.testNode.first(where: { $0.title == "1.2.1.2" }) != nil)
    #expect(Self.testNode.first(where: { $0.title == "zzzzzzzz" }) == nil)
  }

  @Test
  func test_map() {
    expectNoDifference(
      Self.testNode.map { MockNode2($0.title) },
      Self.testNode2)
  }

  @Test
  func test_subscript_singleMemberArray_get() throws {
    let a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ])
    let b = MockNode("c")
    #expect(a[[1]] == b)
  }

  @Test
  func test_subscript_singleMemberArray_set() throws {
    var a = MockNode(
      "a",
      children: [
        MockNode("b"),
        MockNode("c"),
      ])
    a[[1]] = MockNode("z")
    let b = MockNode("z")
    #expect(a[[1]] == b)
  }

  @Test
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
    #expect(a[[0, 0]] == MockNode("y"))
    #expect(a[[1]] == MockNode("c"))
  }

  @Test
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
    #expect(a[[1, 0]] == b)
  }

  @Test
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
    #expect(a[[0, 0]] == MockNode("y"))
  }

  @Test
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
    #expect(a[1, 0] == b)
  }

  // MARK: - Sequence extensions

  @Test
  func test_sortByKeyPath() {
    struct Foo: Equatable {
      let id: Int
      let kind: String
    }
    let a = [Foo(id: 1, kind: "Book"), Foo(id: 0, kind: "Library")]
    let b = a.sorted(by: \.id)
    #expect(b == a.reversed())
  }

  @Test
  func test_grouping() {
    struct Foo: Equatable {
      let name: String
      let kind: String
    }
    let a = [Foo(name: "a", kind: "Book"), Foo(name: "b", kind: "Library")]
    let b = a.dictionary(groupingBy: { $0.kind })
    #expect(
      b ==
        [
          "Book": [a[0]],
          "Library": [a[1]],
        ])
  }

  @Test
  func test_toArray() {
    let a = Set<String>()
    let b = [String]()
    #expect(a.toArray() == b)
  }

  @Test
  func test_toSet() {
    let a = ["a", "a"]
    let b = Set(["a"])
    #expect(a.toSet() == b)
  }

  // MARK: - Dictionary extensions

  @Test
  func test_dictionary() {
    let dict = ["a": 0]
    let key: String? = "a"
    #expect(dict[key] == 0)
    #expect(dict[nil] == nil)
  }

  @Test
  func test_dictionary2() {
    let dict = ["a": [0]]
    let key: String? = "a"
    #expect(dict[key, default: [0]] == [0])
  }

  @Test
  func test_dictionary3() {
    let dict = ["b": [0]]
    let key: String? = "a"
    #expect(dict[key, default: [0]] == [0])
  }

  @Test
  func test_dictionary4() {
    let dict = ["a": [0]]
    let key: String? = nil
    #expect(dict[key, default: [0]] == [0])
  }

  // MARK: -

  @Test
  func test_clamp() {
    #expect(clamp(min: 2, ideal: 999, max: 10) == 10)
    #expect(clamp(min: 2, ideal: 5, max: 10) == 5)
  }

  // MARK: - Cocoa

  @Test
  func test_makeCell() {
    let tv = NSTableView()
    class Foo: NSView { }
    let cell1 = tv.makeView(ofType: Foo.self)
    #expect(cell1.identifier == "Foo")
  }

  // MARK: - Quartz Core

  @Test
  func test_cornerMasks() {
    #expect(CACornerMask.topLeft == .layerMinXMaxYCorner)
    #expect(CACornerMask.topRight == .layerMaxXMaxYCorner)
    #expect(CACornerMask.bottomRight == .layerMaxXMinYCorner)
    #expect(CACornerMask.bottomLeft == .layerMinXMinYCorner)
    #expect(CACornerMask.all == [.topLeft, .topRight, .bottomLeft, .bottomRight])
  }

  // MARK: - Cocoa

  @Test
  func test_NSDirectionalEdgeInsets() {
    let sut = NSDirectionalEdgeInsets(2)
    #expect(sut.top == 2)
    #expect(sut.bottom == 2)
    #expect(sut.leading == 2)
    #expect(sut.trailing == 2)
  }

  @Test
  func test_NSDirectionalEdgeInsets2() {
    let sut = NSDirectionalEdgeInsets(top: 1)
    #expect(sut.top == 1)
    #expect(sut.bottom == 0)
    #expect(sut.leading == 0)
    #expect(sut.trailing == 0)
  }

  @Test
  func test_supplementaryViewKind() {
    class FooView: NSView { }
    let sut = FooView.supplementaryViewKind
    #expect(sut == "FooView")
  }

  @Test
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

    #expect(count == 4)
    #expect(a.subviews[0].identifier == "a")
  }

  // MARK: - NSEvent.ModifierFlags

  @Test
  func test_NSEventModifierFlags_initWithCarbon() throws {
    #expect(NSEvent.ModifierFlags(carbon: cmdKey) == .command)

    var mods = 0
    mods |= cmdKey
    mods |= shiftKey
    mods |= controlKey
    mods |= optionKey
    #expect(NSEvent.ModifierFlags(carbon: mods) == [.command, .shift, .control, .option])
  }

  @Test
  func test_carbonized() throws {
    var mods = 0
    mods |= cmdKey
    mods |= shiftKey
    mods |= controlKey
    mods |= optionKey
    #expect(NSEvent.ModifierFlags([.command, .shift, .control, .option]).carbonized == mods)
  }

  @Test
  func test_hotKeyApplicable() throws {
    let a = NSEvent.ModifierFlags([
      .command, .shift, .control, .option, .function, .capsLock, .numericPad,
    ])
    #expect(a.hotkeyApplicable == [.command, .shift, .control, .option])
  }

  @Test
  func test_description() throws {
    let a = NSEvent.ModifierFlags([.command, .shift, .control, .option].shuffled())
    #expect("\(a)" == "⌃⌥⇧⌘")
  }

  // MARK: Private

  // MARK: - TargetAppTests

  private class _App: NSRunningApplication {
    override var processIdentifier: pid_t { 0 }
    override var bundleIdentifier: String? { "com.foo.bar" }
    override var localizedName: String? { "Foo" }
    override var bundleURL: URL? { URL(fileURLWithPath: "file://apps/foo") }
  }

}
