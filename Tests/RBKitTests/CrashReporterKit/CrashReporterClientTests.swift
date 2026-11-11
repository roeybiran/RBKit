import Dependencies
import Foundation
import RBKitTestSupport
import Testing
@testable import RBKit

// MARK: - CrashReporterClientTests

struct CrashReporterClientTests {
  @Test
  func `With no reports, should return nil`() {
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return []
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `When file manager throws, should return nil`() {
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        throw NSError(domain: "TestError", code: 1)
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `With wrong file extension, should filter out`() {
    let testURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15-120000.txt")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `With wrong filename format, should filter out`() {
    let testURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `With wrong app name, should filter out`() {
    let testURL = URL(fileURLWithPath: "/tmp/WrongApp-2025-01-15-120000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `With invalid time format, should filter out`() {
    let testURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15-1200.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `With invalid date, should filter out`() {
    let testURL = URL(fileURLWithPath: "/tmp/TestApp-2025-13-45-120000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
  }

  @Test
  func `With valid report, should return report and update cache, and call endpoints with correct params`() throws {
    let testContents = "Test crash report contents"
    let testURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15-120000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    nonisolated(unsafe) var userDefaultsSetURLCalled = false

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.stringClient.contentsOf = { url, encoding in
        #expect(url == testURL)
        #expect(encoding == .utf8)
        return testContents
      }
      $0.userDefaultsClient.url = { forKey in
        #expect(forKey == "RBCrashReporter_mostRecentReport")
        return nil
      }
      $0.userDefaultsClient.setURL = { value, key in
        userDefaultsSetURLCalled = true
        #expect(value == testURL)
        #expect(key == "RBCrashReporter_mostRecentReport")
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result?.url == testURL)
    #expect(result?.contents == testContents)
    #expect(userDefaultsSetURLCalled == true)

    let expectedDate = try Date("2025-01-15T12:00:00Z", strategy: .iso8601)
    #expect(result?.date == expectedDate)
  }

  @Test
  func `With multiple reports, should return most recent`() {
    let olderURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15-120000.ips")
    let newerURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-16-130000.ips")
    let oldestURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-14-110000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    nonisolated(unsafe) var userDefaultsSetURLCalled = false

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [olderURL, newerURL, oldestURL]
      }
      $0.stringClient.contentsOf = { url, encoding in
        #expect(encoding == .utf8)
        switch url {
        case olderURL:
          return "Older report"
        case newerURL:
          return "Newer report"
        case oldestURL:
          return "Oldest report"
        default:
          throw NSError(domain: "TestError", code: 1)
        }
      }
      $0.userDefaultsClient.url = { forKey in
        #expect(forKey == "RBCrashReporter_mostRecentReport")
        return nil
      }
      $0.userDefaultsClient.setURL = { value, key in
        userDefaultsSetURLCalled = true
        #expect(value == newerURL)
        #expect(key == "RBCrashReporter_mostRecentReport")
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result?.url == newerURL)
    #expect(result?.contents == "Newer report")
    #expect(userDefaultsSetURLCalled == true)
  }

  @Test
  func `When cached report matches, should return nil`() {
    let testURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15-120000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    nonisolated(unsafe) var userDefaultsSetURLCalled = false

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.stringClient.contentsOf = { url, encoding in
        #expect(url == testURL)
        #expect(encoding == .utf8)
        return "Test contents"
      }
      $0.userDefaultsClient.url = { forKey in
        #expect(forKey == "RBCrashReporter_mostRecentReport")
        return testURL
      }
      $0.userDefaultsClient.setURL = { value, key in
        userDefaultsSetURLCalled = true
        #expect(value == testURL)
        #expect(key == "RBCrashReporter_mostRecentReport")
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result == nil)
    #expect(userDefaultsSetURLCalled == false)
  }

  @Test
  func `When cached report is different, should return new report and update cache`() {
    let cachedURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-14-110000.ips")
    let newURL = URL(fileURLWithPath: "/tmp/TestApp-2025-01-15-120000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    nonisolated(unsafe) var userDefaultsSetURLCalled = false

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [newURL]
      }
      $0.stringClient.contentsOf = { url, encoding in
        #expect(url == newURL)
        #expect(encoding == .utf8)
        return "New report"
      }
      $0.userDefaultsClient.url = { forKey in
        #expect(forKey == "RBCrashReporter_mostRecentReport")
        return cachedURL
      }
      $0.userDefaultsClient.setURL = { value, key in
        userDefaultsSetURLCalled = true
        #expect(value == newURL)
        #expect(key == "RBCrashReporter_mostRecentReport")
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "TestApp")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result?.url == newURL)
    #expect(userDefaultsSetURLCalled == true)
  }

  @Test
  func `With app name containing hyphens, should handle correctly`() throws {
    let appName = "My-App-Name"
    let testContents = "Test crash report contents"
    let testURL = URL(fileURLWithPath: "/tmp/\(appName)-2025-01-15-120000.ips")
    let expectedDirectory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    nonisolated(unsafe) var userDefaultsSetURLCalled = false

    let result = withDependencies {
      $0.fileManagerClient.contentsOfDirectory = { url, keys, options in
        #expect(url == expectedDirectory)
        #expect(keys == [])
        #expect(options == [])
        return [testURL]
      }
      $0.stringClient.contentsOf = { url, encoding in
        #expect(url == testURL)
        #expect(encoding == .utf8)
        return testContents
      }
      $0.userDefaultsClient.url = { forKey in
        #expect(forKey == "RBCrashReporter_mostRecentReport")
        return nil
      }
      $0.userDefaultsClient.setURL = { value, key in
        userDefaultsSetURLCalled = true
        #expect(value == testURL)
        #expect(key == "RBCrashReporter_mostRecentReport")
      }
      $0.bundleClient.main = {
        MockBundleWithAppName(appName: "My-App-Name")
      }
    } operation: {
      CrashReporterClient.mostRecent()
    }

    #expect(result?.url == testURL)
    #expect(result?.contents == testContents)
    #expect(userDefaultsSetURLCalled == true)

    let expectedDate = try Date("2025-01-15T12:00:00Z", strategy: .iso8601)
    #expect(result?.date == expectedDate)
  }
}

// MARK: - MockBundleWithAppName

// Test-only bundle mock stores immutable state and satisfies a Sendable dependency boundary.
// swiftlint:disable:next no_unchecked_sendable
final class MockBundleWithAppName: Bundle.Mock, @unchecked Sendable {

  // MARK: Lifecycle

  init(appName: String) {
    _appName = appName
    super.init()
  }

  // MARK: Internal

  let _appName: String

  override func object(forInfoDictionaryKey key: String) -> Any? {
    if key == kCFBundleNameKey as String {
      return _appName
    } else {
      Issue.record()
      return nil
    }
  }
}
