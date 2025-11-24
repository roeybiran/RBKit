import AppKit
import Dependencies
import Foundation

// MARK: - AppImporterItem

public struct AppImporterItem: Equatable, Identifiable, Sendable {

  // MARK: Lifecycle

  init(
    bundleID: String,
    bundleURL: URL?,
  ) {
    self.bundleID = bundleID
    self.bundleURL = bundleURL
    title = bundleURL?.deletingPathExtension().lastPathComponent ?? bundleID
    path = bundleURL?.path(percentEncoded: false)
  }

  init(bundleID: String) {
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let url = nsWorkspaceClient.urlForApplication(withBundleIdentifier: bundleID)
    self.init(bundleID: bundleID, bundleURL: url)
  }

  init?(url: URL) {
    @Dependency(\.bundleClient) var bundleClient
    guard let bundleID = bundleClient.initWithURL(url: url)?.bundleIdentifier else { return nil }
    self.init(
      bundleID: bundleID,
      bundleURL: url,
    )
  }

  // MARK: Public

  public let bundleID: String
  public let title: String

  public let bundleURL: URL?
  public let path: String?

  public var id: String { bundleID }

  // MARK: Internal

  var image: NSImage {
    if let path {
      NSWorkspace.shared.icon(forFile: path)
    } else {
      .questionMark
    }
  }

}

extension NSImage {
  static let questionMark = NSImage(systemSymbolName: "questionmark.app", accessibilityDescription: nil) ?? .init()
}
