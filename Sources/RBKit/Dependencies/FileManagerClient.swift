import Dependencies
import DependenciesMacros
import Foundation

// MARK: - FileManagerClient

@DependencyClient
public struct FileManagerClient: Sendable {
  public var urls:
    @Sendable (
      _ directory: FileManager.SearchPathDirectory,
      _ domainMask: FileManager.SearchPathDomainMask
    ) -> [URL] = { _, _ in [] }
  public var contentsOfDirectory:
    @Sendable (
      _ url: URL,
      _ keys: [URLResourceKey]?,
      _ options: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL]
  public var createDirectory:
    @Sendable (
      _ atURL: URL,
      _ withIntermediateDirectories: Bool,
      _ attributes: [FileAttributeKey: Any]?
    ) throws
      -> Void
}

// MARK: DependencyKey

extension FileManagerClient: DependencyKey {
  public static let liveValue = FileManagerClient(
    urls: { FileManager.default.urls(for: $0, in: $1) },
    contentsOfDirectory: {
      try FileManager.default.contentsOfDirectory(
        at: $0, includingPropertiesForKeys: $1, options: $2)
    },
    createDirectory: {
      try FileManager.default.createDirectory(
        at: $0, withIntermediateDirectories: $1, attributes: $2)
    })
  public static let testValue = FileManagerClient()
}

extension DependencyValues {
  public var fileManagerClient: FileManagerClient {
    get { self[FileManagerClient.self] }
    set { self[FileManagerClient.self] = newValue }
  }
}
