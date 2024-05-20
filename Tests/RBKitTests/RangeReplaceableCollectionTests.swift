import XCTest
import CustomDump

@testable import RBKit

final class RangeReplaceableCollectionTests: XCTestCase {
  func test_append() {
    var sut = ["a"]
    sut.append("b", "c")
    XCTAssertEqual(sut, ["a", "b", "c"])
  }
}
