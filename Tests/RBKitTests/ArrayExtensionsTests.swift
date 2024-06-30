import Carbon
import CustomDump
import XCTest
@testable import RBKit

final class ArrayExtensionsTests: XCTestCase {
  func test_concat() {
    let a = ["a"].concat(["b"])
    XCTAssertEqual(a, ["a", "b"])

    let b = ["a"].concat("b")
    XCTAssertEqual(b, ["a", "b"])
  }

  func test_subscript_safe_get() {
    var a = ["a", "b", "c"]

    XCTAssertEqual(a[safe: 3], nil)
    XCTAssertEqual(a[safe: 0], "a")
    a[safe: 0] = "z"
    XCTAssertEqual(a[safe: 0], "z")
    a[safe: 9] = "y"
    XCTAssertEqual(a[safe: 9], nil)
  }
}
