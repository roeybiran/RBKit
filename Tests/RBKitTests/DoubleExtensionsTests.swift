import Dependencies
import XCTest
@testable import RBKit

final class DoubleExtensionsTests: XCTestCase {
  func test() {
    let a = Double(360).radians
    XCTAssertEqual(a, 2 * .pi)
  }
}
