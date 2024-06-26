import XCTest
import Dependencies
@testable import RBKit

final class CGWindowTests: XCTestCase {
  var dict = [CFString: Any]()

  override func setUp() {
    dict[kCGWindowNumber] = CGWindowID()
    dict[kCGWindowStoreType] = 0
    dict[kCGWindowLayer] = Int32()
    dict[kCGWindowBounds] = ["X": 0.0, "Y": 0.0, "Width": 0.0, "Height": 0.0] as CFDictionary
    dict[kCGWindowSharingState] = 0
    dict[kCGWindowAlpha] = CGFloat()
    dict[kCGWindowOwnerPID] = pid_t()
    dict[kCGWindowMemoryUsage] = 0
  }

  override func tearDown() {
    dict = [:]
  }

  func test_init() async throws {
    let a = CGWindowValue(dict)
    let b = CGWindowValue(
      number: 0,
      storeType: 0,
      layer: 0,
      bounds: .zero,
      sharingState: 0,
      alpha: 0,
      ownerPID: 0,
      memoryUsage: 0,
      ownerName: nil,
      name: nil,
      isOnscreen: nil,
      backingLocationVideoMemory: nil
    )
    XCTAssertEqual(a, b)
  }

  func test_withoutWindowNumber() async throws {
    dict[kCGWindowNumber] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutWindowStoreType() async throws {
    dict[kCGWindowStoreType] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutWindowLayer() async throws {
    dict[kCGWindowLayer] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutBounds() async throws {
    dict[kCGWindowBounds] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withOnlyX() async throws {
    dict[kCGWindowBounds] = ["X": CGFloat()]
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withOnlyY() async throws {
    dict[kCGWindowBounds] = ["Y": CGFloat()]
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withOnlyW() async throws {
    dict[kCGWindowBounds] = ["Width": CGFloat()]
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withOnlyH() async throws {
    dict[kCGWindowBounds] = ["Height": CGFloat()]
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutSharingState() async throws {
    dict[kCGWindowSharingState] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutAlpha() async throws {
    dict[kCGWindowAlpha] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutOwnerPID() async throws {
    dict[kCGWindowOwnerPID] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

  func test_withoutMemUsage() async throws {
    dict[kCGWindowMemoryUsage] = nil
    let a = CGWindowValue(dict)
    XCTAssertEqual(a, nil)
  }

}
