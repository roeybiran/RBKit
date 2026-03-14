import AppKit
import Dependencies
import Testing
@testable import RBKit

struct `NSWorkspaceClient Tests` {
  @Test
  @MainActor
  func `open(itemURLs:withApplicationAt:configuration:), should route to openItemURLs`() async throws {
    let itemURLs = [
      URL(filePath: "/tmp/Test.txt"),
      URL(filePath: "/tmp/Test Folder", directoryHint: .isDirectory),
    ]
    let applicationURL = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()

    let result = try await withDependencies {
      $0.nsWorkspaceClient.openItemURLs = { openedItemURLs, openedApplicationURL, openedConfiguration in
        #expect(openedItemURLs == itemURLs)
        #expect(openedApplicationURL == applicationURL)
        #expect(openedConfiguration.createsNewApplicationInstance == configuration.createsNewApplicationInstance)
        return .current
      }
    } operation: {
      @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
      return try await nsWorkspaceClient.open(
        itemURLs: itemURLs,
        withApplicationAt: applicationURL,
        configuration: configuration
      )
    }

    #expect(result.processIdentifier == NSRunningApplication.current.processIdentifier)
  }

  @Test
  @MainActor
  func `open(url:configuration:), should route to openURLWithConfiguration`() async throws {
    let url = URL(filePath: "/Applications/Test.app", directoryHint: .isDirectory)
    let configuration = NSWorkspace.OpenConfiguration()

    let result = try await withDependencies {
      $0.nsWorkspaceClient.openURLWithConfiguration = { openedURL, openedConfiguration in
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
}
