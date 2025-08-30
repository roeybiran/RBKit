import AppKit
import Carbon
import CustomDump
import Testing

@testable import RBKit

// MARK: - RBKitTests

@MainActor
struct RBKitTests {

  // MARK: - Collection Extensions

  @Test
  func safe_subscript() {
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
  func itemAt() {
    let a = [1, 2, 3]
    #expect(a.item(at: 1) == 2)
  }

  @Test
  func itemOptionallyAt() {
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
  func replaceEmpty2() {
    let a = [1]
    let b = a.replaceEmpty(with: [0])
    #expect(b == [1])
  }

  @Test
  func replaceEmptyWithOptional() {
    let a = [Int]()
    let b = a.replaceEmpty(with: nil)
    #expect(b == nil)
  }

  @Test
  func replaceEmptyWithOptional2() {
    let a = [1]
    let b = a.replaceEmpty(with: nil)
    #expect(b == [1])
  }

  // MARK: - NSEventValue

  @Test
  func keyEventInitFromNSEvent_withKeyDown_shouldCreateEvent() {
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

    expectNoDifference(actual, expected)
  }

  @Test
  func keyEventInitFromNSEvent_withKeyUp_shouldCreateEvent() {
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

    expectNoDifference(actual, expected)
  }

  @Test
  func keyEventInitFromNSEvent_withNonKeyEvent_shouldBeNil() {
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
    expectNoDifference(actual, nil)
  }

  @Test
  func keyEventUpArrow() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventRightArrow() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventDownArrow() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventLeftArrow() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventPageUp() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventPageDown() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventHome() {
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
    #expect(actual == expected)
  }

  @Test
  func keyEventEnd() {
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
    #expect(actual == expected)
  }

  @Test
  func DotSyntaxSettable() {
    let a = NSTextField()
    a.set(\.stringValue, to: "foo")
    #expect(a.stringValue == "foo")
  }

  // MARK: - IdentifiedHash

  @Test
  func identifiedHash() {
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

  // MARK: - Sequence extensions

  @Test
  func sortByKeyPath() {
    struct Foo: Equatable {
      let id: Int
      let kind: String
    }
    let a = [Foo(id: 1, kind: "Book"), Foo(id: 0, kind: "Library")]
    let b = a.sorted(by: \.id)
    #expect(b == a.reversed())
  }

  @Test
  func grouping() {
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
        ]
    )
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

  // MARK: -

  @Test
  func test_clamp() {
    #expect(clamp(min: 2, ideal: 999, max: 10) == 10)
    #expect(clamp(min: 2, ideal: 5, max: 10) == 5)
  }

  // MARK: - Cocoa

  @Test
  func makeCell() {
    let tv = NSTableView()
    class Foo: NSView { }
    let cell1 = tv.makeView(ofType: Foo.self)
    #expect(cell1.identifier == "Foo")
  }

  // MARK: - Quartz Core

  @Test
  func cornerMasks() {
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
  func NSDirectionalEdgeInsets2() {
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
  func NSEventModifierFlags_initWithCarbon() throws {
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
  func hotKeyApplicable() throws {
    let a = NSEvent.ModifierFlags([
      .command, .shift, .control, .option, .function, .capsLock, .numericPad,
    ])
    #expect(a.hotkeyApplicable == [.command, .shift, .control, .option])
  }

  @Test
  func description() throws {
    let a = NSEvent.ModifierFlags([.command, .shift, .control, .option].shuffled())
    #expect("\(a)" == "⌃⌥⇧⌘")
  }
}
