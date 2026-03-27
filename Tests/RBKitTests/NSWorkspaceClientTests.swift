import AppKit
import Dependencies
import DependenciesTestSupport
import Testing
import UniformTypeIdentifiers
@testable import RBKit

struct `NSWorkspaceClient Tests` {
  @Test(
    .dependencies {
      $0.nsWorkspaceClient.openURLWithConfiguration = { openedURL, openedConfiguration in
        #expect(openedURL == URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory))
        #expect(openedConfiguration.createsNewApplicationInstance)
        return .current
      }
    }
  )
  @MainActor
  func `open(url:configuration:), should route to openURLWithConfiguration`() async throws {
    let url = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.createsNewApplicationInstance = true
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = try await nsWorkspaceClient.open(url: url, configuration: configuration)

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.openURLsWithApplicationAt = { openedURLs, openedApplicationURL, openedConfiguration in
        #expect(openedURLs == [
          URL(filePath: "/tmp/Test.txt"),
          URL(filePath: "/tmp/Test Folder", directoryHint: .isDirectory),
        ])
        #expect(openedApplicationURL == URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory))
        #expect(openedConfiguration.createsNewApplicationInstance)
        return .current
      }
    }
  )
  @MainActor
  func `open(itemURLs:withApplicationAt:configuration:), should route to openURLsWithApplicationAt`() async throws {
    let urls = [
      URL(filePath: "/tmp/Test.txt"),
      URL(filePath: "/tmp/Test Folder", directoryHint: .isDirectory),
    ]
    let applicationURL = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.createsNewApplicationInstance = true
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = try await nsWorkspaceClient.open(
      itemURLs: urls,
      withApplicationAt: applicationURL,
      configuration: configuration,
    )

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.open = { openedURL in
        #expect(openedURL == URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory))
        return true
      }
    }
  )
  @MainActor
  func `open(url:), should route to open`() {
    let url = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = nsWorkspaceClient.open(url: url)

    #expect(result)
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.openApplication = { openedApplicationURL, openedConfiguration in
        #expect(openedApplicationURL == URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory))
        #expect(openedConfiguration.createsNewApplicationInstance)
        return .current
      }
    }
  )
  @MainActor
  func `openApplication, should route to openApplication`() async throws {
    let applicationURL = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.createsNewApplicationInstance = true
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = try await nsWorkspaceClient.openApplication(applicationURL, configuration)

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.iconForFile = { queriedPath in
        #expect(queriedPath == "/Applications/Test.app")
        return NSImage(size: .init(width: 1, height: 1))
      }
    }
  )
  @MainActor
  func `icon(forFile:), should route to iconForFile`() {
    let filePath = "/Applications/Test.app"
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = nsWorkspaceClient.icon(forFile: filePath)

    #expect(result.size == .init(width: 1, height: 1))
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.iconForContentType = { queriedContentType in
        #expect(queriedContentType == .plainText)
        return NSImage(size: .init(width: 1, height: 1))
      }
    }
  )
  @MainActor
  func `icon(for:), should route to iconForContentType`() {
    let contentType = UTType.plainText
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = nsWorkspaceClient.icon(for: contentType)

    #expect(result.size == .init(width: 1, height: 1))
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.menuBarOwningApplicationChanges = { options in
        #expect(options == [.initial, .new])
        return .init { continuation in
          continuation.yield(
            .init(
              kind: .setting,
              oldValue: nil,
              newValue: .current,
              indexes: nil,
              isPrior: false,
            )
          )
          continuation.finish()
        }
      }
    }
  )
  @MainActor
  func `menuBarOwningApplicationChanges, should route to menuBarOwningApplicationChanges`() async {
    let expectedApp = NSRunningApplication.current
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let result = await {
      for await change in nsWorkspaceClient.menuBarOwningApplicationChanges([.initial, .new]) {
        if let newValue = change.newValue {
          return newValue
        }
      }
      return nil
    }()

    #expect(result?.processIdentifier == expectedApp.processIdentifier)
  }
}
