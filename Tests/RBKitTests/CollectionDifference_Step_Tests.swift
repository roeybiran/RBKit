import XCTest
@testable import RBKit

final class CollectionDifference_Change_Step_Tests: XCTestCase {
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

}

