import XCTest
import CustomDump
@testable import RBKit

final class Collection_Plus_Tests: XCTestCase {
  // MARK: - CollectionDifferenceChange

  func test_collectionDifferenceCHange() {
    let a = ["a", "b", "c"]
    let b = ["a", "c", "b"]

    let diff = b.difference(from: a).inferringMoves()

    let insertion = diff.insertions[0]
    let removal = diff.removals[0]

    XCTAssertEqual(insertion.offset, 2)
    XCTAssertEqual(insertion.element, "b")
    XCTAssertEqual(insertion.associatedWith, 1)

    XCTAssertEqual(removal.offset, 1)
    XCTAssertEqual(removal.element, "b")
    XCTAssertEqual(removal.associatedWith, 2)
  }

  // MARK: - CollectionDifference Step

  func test_insert() {
    let a = CollectionDifference.Change.insert(offset: 1, element: "a", associatedWith: nil).step
    let b = CollectionDifference.Step.inserted(element: "a", at: 1)
    XCTAssertEqual(a, b)
  }

  func test_remove() {
    let a = CollectionDifference.Change.remove(offset: 2, element: "b", associatedWith: nil).step
    let b = CollectionDifference.Step.removed(element: "b", from: 2)
    XCTAssertEqual(a, b)
  }

  func test_move() {
    let a = CollectionDifference.Change.remove(offset: 2, element: "c", associatedWith: 9).step
    let b = CollectionDifference.Step.moved(element: "c", from: 2, to: 9)
    XCTAssertEqual(a, b)
  }

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
    a.setting(\.stringValue, to: "foo")
    XCTAssertEqual(a.stringValue, "foo")
  }


}
