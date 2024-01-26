import XCTest
@testable import RBKit

final class KeyEvent_Tests: XCTestCase {
  func test_keyEventInit() {
    let actual = NSEventValue(characters: "a", charactersIgnoringModifiers: "a", keyCode: 0)
    let expected = NSEventValue(
      _type: .keyDown,
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

}
