import XCTest
@testable import RBKit

final class CollectionDifference_Change_Plus_Tests: XCTestCase {
  func test() {
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
}
