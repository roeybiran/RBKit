import Dependencies
import Foundation
import Testing

@testable import RBKit

typealias TestFrecencyStore = FrecencyStore<String>

// MARK: - TestError

struct TestError: Error { }

// MARK: - FrecencyStoreTests

@Suite
struct `FrecencyStore Tests` {
  @Test
  func getURL() async throws {
    nonisolated(unsafe) var called_urls = false
    nonisolated(unsafe) var called_createDirectory = false

    _ = withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in
        called_urls = true
        return URL(filePath: "/Users/roey/app_support/")
      }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable url, withIntermediateDirs, attrs in
        #expect(URL(filePath: "/Users/roey/app_support/com.foo.bar/") == url)
        #expect(withIntermediateDirs)
        #expect(attrs == nil)
        called_createDirectory = true
      }
    } operation: {
      TestFrecencyStore.defaultURL()
    }

    #expect(called_urls)
    #expect(called_createDirectory)
  }

  @Test
  func getURL_with_bundleIdentifier_nil() async throws {
    let sut = withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in URL(filePath: "/Users/roey/app_support/") }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in nil }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
      $0.diskClient.read = { @Sendable _ in "[0]".data(using: .utf8)! }
    } operation: {
      TestFrecencyStore.defaultURL()
    }

    #expect(sut == nil)
  }

  @Test
  func getURL_with_createDirectory_failing() async throws {
    let sut = withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in URL(filePath: "/Users/roey/app_support/") }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in throw TestError() }
      $0.diskClient.read = { @Sendable _ in "[0]".data(using: .utf8)! }
    } operation: {
      TestFrecencyStore.defaultURL()
    }

    #expect(sut == nil)
  }

  @Test
  func load() async throws {
    try await confirmation { c in
      var sut = withDependencies {
        $0.diskClient.read = { @Sendable url in
          #expect(testURL == url)
          c()
          return makeTestJSON()
        }
      } operation: {
        TestFrecencyStore(url: testURL)
      }

      #expect(sut.score(for: "a") == 0)
      try sut.load()
      #expect(sut.score(for: "a") == 100)
    }
  }

  @Test
  func load_withoutURL_shouldNoOp() async throws {
    var sut = withDependencies {
      $0.diskClient.read = { @Sendable _ in fatalError("should not get here") }
    } operation: {
      TestFrecencyStore(url: nil)
    }

    try sut.load()
  }

  @Test
  func load_with_readError_shouldThrow() async throws {
    var sut = withDependencies {
      $0.diskClient.read = { @Sendable _ in throw TestError() }
    } operation: {
      TestFrecencyStore(url: testURL)
    }

    #expect(throws: (any Error).self) { try sut.load() }
  }

  @Test
  func load_with_invalidJson_shouldThrow() async throws {
    var sut = withDependencies {
      $0.diskClient.read = { @Sendable _ in "foo".data(using: .utf8)! }
    } operation: {
      TestFrecencyStore(url: testURL)
    }

    #expect(throws: (any Error).self) { try sut.load() }
  }

  @Test
  func save() async throws {
    try await confirmation { c in
      var sut = withDependencies {
        $0.diskClient.read = { @Sendable _ in makeTestJSON(date: 0) }
        $0.diskClient.write = { @Sendable data, url, _ in
          let expectedDecoded = FrecencyCollection<String>(items: [
            "a": .init(id: "a", visits: [.init(timeIntervalSinceReferenceDate: 0)], count: 1)
          ])
          let actualDecoded = try! JSONDecoder().decode(FrecencyCollection<String>.self, from: data)
          #expect(expectedDecoded == actualDecoded)
          #expect(url == testURL)
          c()
        }
      } operation: {
        TestFrecencyStore(url: testURL)
      }

      try sut.load()
      try sut.save()
    }
  }

  @Test(.disabled())
  func save_withJSONEncodingError_shouldNoOp() async throws {
    let sut = withDependencies {
      $0.diskClient.write = { @Sendable _, _, _ in }
    } operation: {
      TestFrecencyStore(url: nil)
    }

    try sut.save()
  }

  @Test
  func save_withDiskWriteError_shouldThrow() async throws {
    let sut = withDependencies {
      $0.diskClient.write = { @Sendable _, _, _ in throw TestError() }
    } operation: {
      TestFrecencyStore(url: testURL)
    }

    #expect(throws: (any Error).self) { try sut.save() }
  }

  @Test
  func save_withoutURL_shouldNoOp() async throws {
    let sut = withDependencies {
      $0.diskClient.write = { @Sendable _, _, _ in fatalError("should not get here") }
    } operation: {
      TestFrecencyStore(url: nil)
    }

    try sut.save()
  }

  @Test
  func add() async throws {
    var sut = TestFrecencyStore(url: testURL)

    #expect(sut.score(for: "a") == 0)
    sut.add("a")
    #expect(sut.score(for: "a") == 100)
  }

}

let testURL = URL(filePath: "/Users/roey/app_support/com.foo.bar/recents.json")

func makeTestJSON(date: Double = Date.now.timeIntervalSince1970) -> Data {
  "{ \"items\": { \"a\": { \"id\": \"a\", \"visits\": [\(date)], \"count\": 1, \"_reduced\": false } }, \"queries\": {} }"
    .data(using: .utf8)!
}
