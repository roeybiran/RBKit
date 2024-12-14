import XCTest
@testable import RBKit

final class CGSizeClampTests: XCTestCase {
  func testClampSmallerSize() {
    let originalSize = CGSize(width: 100, height: 50)
    let maxSize = CGSize(width: 200, height: 100)

    let clampedSize = originalSize.clamp(to: maxSize)

    XCTAssertEqual(clampedSize.width, 100)
    XCTAssertEqual(clampedSize.height, 50)
  }

  func testClampLargerSize() {
    let originalSize = CGSize(width: 400, height: 300)
    let maxSize = CGSize(width: 200, height: 150)

    let clampedSize = originalSize.clamp(to: maxSize)

    XCTAssertEqual(clampedSize.width, 200)
    XCTAssertEqual(clampedSize.height, 150)
  }

  func testClampWithAspectRatioMaintained() {
    let originalSize = CGSize(width: 400, height: 200)
    let maxSize = CGSize(width: 200, height: 200)

    let clampedSize = originalSize.clamp(to: maxSize)

    XCTAssertEqual(clampedSize.width, 200)
    XCTAssertEqual(clampedSize.height, 100)
  }

  func testClampWithZeroDimensions() {
    let originalSize = CGSize(width: 0, height: 0)
    let maxSize = CGSize(width: 200, height: 200)

    let clampedSize = originalSize.clamp(to: maxSize)

    XCTAssertEqual(clampedSize.width, 0)
    XCTAssertEqual(clampedSize.height, 0)
  }

  func testClampWithNegativeDimensions() {
    let originalSize = CGSize(width: -100, height: -50)
    let maxSize = CGSize(width: 200, height: 200)

    let clampedSize = originalSize.clamp(to: maxSize)

    XCTAssertEqual(clampedSize.width, -100)
    XCTAssertEqual(clampedSize.height, -50)
  }
}
