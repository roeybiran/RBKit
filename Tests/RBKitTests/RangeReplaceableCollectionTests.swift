import CustomDump
import XCTest

@testable import RBKit

final class RangeReplaceableCollectionTests: XCTestCase {
  func test_append() {
    var sut = ["a"]
    sut.append("b", "c")
    XCTAssertEqual(sut, ["a", "b", "c"])
  }
}
