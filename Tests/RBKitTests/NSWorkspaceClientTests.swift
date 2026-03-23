import AppKit
import Dependencies
import Testing
import UniformTypeIdentifiers
@testable import RBKit

struct `NSWorkspaceClient Tests` {
  @Test
  @MainActor
  func `open(url:configuration:), should route to openWithConfiguration`() async throws {
    let url = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()

    let result = try await withDependencies {
      $0.nsWorkspaceClient.openWithConfiguration = { openedURL, openedConfiguration in
        #expect(openedURL == url)
        #expect(openedConfiguration.createsNewApplicationInstance == configuration.createsNewApplicationInstance)
        return .current
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return try await nsWorkspaceClient.open(url: url, configuration: configuration)
    }

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test
  @MainActor
  func `open(itemURLs:withApplicationAt:configuration:), should route to openWithApplicationAt`() async throws {
    let urls = [
      URL(filePath: "/tmp/Test.txt"),
      URL(filePath: "/tmp/Test Folder", directoryHint: .isDirectory),
    ]
    let applicationURL = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()

    let result = try await withDependencies {
      $0.nsWorkspaceClient.openWithApplicationAt = { openedURLs, openedApplicationURL, openedConfiguration in
        #expect(openedURLs == urls)
        #expect(openedApplicationURL == applicationURL)
        #expect(openedConfiguration.createsNewApplicationInstance == configuration.createsNewApplicationInstance)
        return .current
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return try await nsWorkspaceClient.open(
        itemURLs: urls,
        withApplicationAt: applicationURL,
        configuration: configuration
      )
    }

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test
  @MainActor
  func `open(url:), should route to open`() {
    let url = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let result = withDependencies {
      $0.nsWorkspaceClient.open = { openedURL in
        #expect(openedURL == url)
        return true
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return nsWorkspaceClient.open(url: url)
    }

    #expect(result)
  }

  @Test
  @MainActor
  func `openApplication(at:configuration:), should route to openApplicationAt`() async throws {
    let applicationURL = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()

    let result = try await withDependencies {
      $0.nsWorkspaceClient.openApplicationAt = { openedApplicationURL, openedConfiguration in
        #expect(openedApplicationURL == applicationURL)
        #expect(openedConfiguration.createsNewApplicationInstance == configuration.createsNewApplicationInstance)
        return .current
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return try await nsWorkspaceClient.openApplication(at: applicationURL, configuration: configuration)
    }

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test
  @MainActor
  func `icon(forFile:), should route to iconForFile`() {
    let filePath = "/Applications/Test.app"
    let expectedIcon = NSImage()

    let result = withDependencies {
      $0.nsWorkspaceClient.iconForFile = { queriedPath in
        #expect(queriedPath == filePath)
        return expectedIcon
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return nsWorkspaceClient.icon(forFile: filePath)
    }

    #expect(result === expectedIcon)
  }

  @Test
  @MainActor
  func `icon(for:), should route to iconForContentType`() {
    let contentType = UTType.plainText
    let expectedIcon = NSImage()

    let result = withDependencies {
      $0.nsWorkspaceClient.iconForContentType = { queriedContentType in
        #expect(queriedContentType == contentType)
        return expectedIcon
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return nsWorkspaceClient.icon(for: contentType)
    }

    #expect(result === expectedIcon)
  }

  @Test
  @MainActor
  func `menuBarOwningApplicationChanges, should route to menuBarOwningApplicationChanges`() async {
    let expectedApp = NSRunningApplication.current

    let result = await withDependencies {
      $0.nsWorkspaceClient.menuBarOwningApplicationChanges = { options in
        #expect(options == [.initial, .new])
        return .init { continuation in
          continuation.yield(
            .init(
              kind: .setting,
              oldValue: nil,
              newValue: expectedApp,
              indexes: nil,
              isPrior: false,
            )
          )
          continuation.finish()
        }
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      for await change in nsWorkspaceClient.menuBarOwningApplicationChanges([.initial, .new]) {
        if let newValue = change.newValue {
          return newValue
        }
      }
      return nil
    }

    #expect(result?.processIdentifier == expectedApp.processIdentifier)
  }
}
