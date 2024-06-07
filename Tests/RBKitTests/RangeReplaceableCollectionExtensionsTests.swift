import XCTest
@testable import RBKit

final class RangeReplaceableCollectionExtensionsTests: XCTestCase {
  func test_append() {
    var sut = ["a"]
    sut.append("b", "c")
    XCTAssertEqual(sut, ["a", "b", "c"])
  }
}
