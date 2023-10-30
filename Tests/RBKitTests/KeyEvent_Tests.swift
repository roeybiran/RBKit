import XCTest
@testable import RBKit

final class KeyEvent_Tests: XCTestCase {
  func test_keyEventInit() {
    let actual = KeyEvent(keyCode: 0, characters: "a", charactersIgnoringModifiers: "a")
    let expected = KeyEvent(
      keyCode: 0,
      characters: "a",
      charactersIgnoringModifiers: "a",
      type: .keyDown,
      modifiers: [],
      repeating: false)
    XCTAssertEqual(actual, expected)
  }

  func test_keyEventDownArrow() {
    let actual = KeyEvent.downArrow()
    XCTAssertEqual(actual.keyCode, 125)
    XCTAssertEqual(actual.characters?.count, 1)
    XCTAssertEqual(actual.charactersIgnoringModifiers?.count, 1)
  }

  func test_keyEventUpArrow() {
    let actual = KeyEvent.upArrow()
    XCTAssertEqual(actual.keyCode, 126)
    XCTAssertEqual(actual.characters?.count, 1)
    XCTAssertEqual(actual.charactersIgnoringModifiers?.count, 1)
  }

}
