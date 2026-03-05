import AppKit
import Dependencies
import Foundation

// MARK: - AppImporterItem

public struct AppImporterItem: Hashable, Identifiable, Sendable, Codable {

  // MARK: Lifecycle

  public init(bundleID: String) {
    self.bundleID = bundleID
  }

  // MARK: Public

  public let bundleID: String

  public var id: String { bundleID }

  public var title: String {
    resolvedApplicationURL?.deletingPathExtension().lastPathComponent ?? bundleID
  }

  public var image: NSImage {
    if let path = resolvedApplicationURL?.path(percentEncoded: false) {
      NSWorkspace.shared.icon(forFile: path)
    } else {
      .questionMark
    }
  }

  // MARK: Private

  private var resolvedApplicationURL: URL? {
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    return nsWorkspaceClient.urlForApplication(withBundleIdentifier: bundleID)
  }

}

extension NSImage {
  static let questionMark = NSImage(systemSymbolName: "questionmark.app", accessibilityDescription: nil) ?? .init()
}
