import AppKit
import Dependencies
import Testing
@testable import RBKit

struct `NSWorkspaceClient Tests` {
  @Test
  @MainActor
  func `open(_:withApplicationAt:configuration:), should route to openWithApplicationAt`() async throws {
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
        urls,
        withApplicationAt: applicationURL,
        configuration: configuration
      )
    }

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test
  @MainActor
  func `open(_:configuration:), should route to openWithConfiguration`() async throws {
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
      return try await nsWorkspaceClient.open(url, configuration: configuration)
    }

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }
}
