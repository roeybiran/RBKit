import Dependencies
import DependenciesTestSupport
import Foundation
import Testing

@testable import RBKit

typealias TestFrecencyStore = FrecencyStore<String>
typealias TestFrecencyStoreClient = FrecencyStoreClient<String>

// MARK: - TestError

struct TestError: Error { }

// MARK: - FrecencyStoreTests

struct FrecencyStoreTests {
  @Test
  func `get frecency URL`() {
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
      URL.frecencyURL
    }

    #expect(called_urls)
    #expect(called_createDirectory)
  }

  @Test(
    .dependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in URL(filePath: "/Users/roey/app_support/") }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in nil }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
    }
  )
  func `get frecency URL with bundle identifier nil`() {
    let sut = URL.frecencyURL

    #expect(sut == URL(filePath: "/Users/roey/app_support/recents.json"))
  }

  @Test(
    .dependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in URL(filePath: "/Users/roey/app_support/") }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in throw TestError() }
    }
  )
  func `get frecency URL with create directory failing`() {
    let sut = URL.frecencyURL

    #expect(sut == URL(filePath: "/Users/roey/app_support/recents.json"))
  }

  @Test
  func `collection persists across stores with same URL`() {
    let applicationSupportDirectory = uniqueApplicationSupportDirectory()

    withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in applicationSupportDirectory }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
    } operation: {
      var writer = TestFrecencyStore()

      writer.add("a")

      let reader = TestFrecencyStore()

      #expect(reader.score(for: "a") == 100)
    }
  }

  @Test
  func `stores with different URLs do not share state`() {
    withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in uniqueApplicationSupportDirectory() }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
    } operation: {
      var writer = TestFrecencyStore()

      writer.add("a")
    }

    withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in uniqueApplicationSupportDirectory() }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
    } operation: {
      let reader = TestFrecencyStore()

      #expect(reader.score(for: "a") == 0)
    }
  }

  @Test
  func add() {
    let applicationSupportDirectory = uniqueApplicationSupportDirectory()

    withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in applicationSupportDirectory }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
    } operation: {
      var sut = TestFrecencyStore()

      #expect(sut.score(for: "a") == 0)
      sut.add("a")
      #expect(sut.score(for: "a") == 100)
    }
  }

  @Test
  func `client live value`() {
    let applicationSupportDirectory = uniqueApplicationSupportDirectory()

    withDependencies {
      $0.urlClient.applicationSupportDirectory = { @Sendable in applicationSupportDirectory }
      $0.bundleClient.main = { .init() }
      $0.bundleClient.bundleIdentifier = { @Sendable _ in "com.foo.bar" }
      $0.fileManagerClient.createDirectory = { @Sendable _, _, _ in }
    } operation: {
      let sut = TestFrecencyStoreClient.liveValue

      #expect(sut.score("a") == 0)
      sut.add("a")
      #expect(sut.score("a") == 100)
    }
  }

  @Test
  func `client test value`() {
    _ = TestFrecencyStoreClient.testValue
  }

}

func uniqueApplicationSupportDirectory() -> URL {
  URL(filePath: "/Users/roey/app_support/\(UUID().uuidString)/")
}
