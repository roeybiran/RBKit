import Dependencies
import DependenciesMacros
import Foundation

// MARK: - FileManagerClient

@DependencyClient
public struct FileManagerClient: Sendable {
  public var url: @Sendable (
    _ directory: FileManager.SearchPathDirectory,
    _ domain: FileManager.SearchPathDomainMask,
    _ appropriateFor: URL?,
    _ create: Bool
  ) throws -> URL

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

  public var enumerator:
    @Sendable (
      _ url: URL,
      _ resourceKeys: [URLResourceKey]?,
      _ options: FileManager.DirectoryEnumerationOptions,
      _ errorHandler: (
        (
          URL,
          Error
        ) -> Bool
      )?
    ) -> FileManager.DirectoryEnumerator?

  public var createDirectory:
    @Sendable (
      _ atURL: URL,
      _ withIntermediateDirectories: Bool,
      _ attributes: [FileAttributeKey: Any]?
    ) throws -> Void
}

// MARK: DependencyKey

extension FileManagerClient: DependencyKey {
  public static let liveValue = FileManagerClient(
    url: { try FileManager.default.url(for: $0, in: $1, appropriateFor: $2, create: $3) },
    urls: { FileManager.default.urls(for: $0, in: $1) },
    contentsOfDirectory: {
      try FileManager.default.contentsOfDirectory(
        at: $0, includingPropertiesForKeys: $1, options: $2
      )
    },
    enumerator: {
      FileManager.default.enumerator(at: $0, includingPropertiesForKeys: $1, options: $2, errorHandler: $3)
    },
    createDirectory: {
      try FileManager.default.createDirectory(
        at: $0, withIntermediateDirectories: $1, attributes: $2
      )
    }
  )
  public static let testValue = FileManagerClient()
}

extension DependencyValues {
  public var fileManagerClient: FileManagerClient {
    get { self[FileManagerClient.self] }
    set { self[FileManagerClient.self] = newValue }
  }
}
