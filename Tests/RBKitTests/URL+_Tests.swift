import XCTest
@testable import RBKit

final class BackportURL_Tests: XCTestCase {
  func test_appending_queryItems() {
    let actual = URL(fileURLWithPath: "/Users/roey/file.txt").appending(queryItems: [.init(name: "id", value: "foo")])
    let expected = URL(string: "file:///Users/roey/file.txt?id=foo")
    XCTAssertEqual(actual, expected)
  }

  func test__appending_queryItems() {
    let actual = URL(fileURLWithPath: "/Users/roey/file.txt")._appending(queryItems: [.init(name: "id", value: "foo")])
    let expected = URL(string: "file:///Users/roey/file.txt?id=foo")
    XCTAssertEqual(actual, expected)
  }

  func test__directoryHint() {
    XCTAssertEqual(URL._DirectoryHint.isDirectory.directoryHint(), .isDirectory)
    XCTAssertEqual(URL._DirectoryHint.notDirectory.directoryHint(), .notDirectory)
    XCTAssertEqual(URL._DirectoryHint.checkFileSystem.directoryHint(), .checkFileSystem)
    XCTAssertEqual(URL._DirectoryHint.inferFromPath.directoryHint(), .inferFromPath)
  }
}
