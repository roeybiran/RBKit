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
  
  public var fileExists:
    @Sendable (
      _ atPath: String
    ) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension FileManagerClient: DependencyKey {
  public static let liveValue = FileManagerClient(
    url: FileManager.default.url(for:in:appropriateFor:create:),
    urls: FileManager.default.urls(for:in:),
    contentsOfDirectory: FileManager.default.contentsOfDirectory(at:includingPropertiesForKeys:options:),
    enumerator: FileManager.default.enumerator(at:includingPropertiesForKeys:options:errorHandler:),
    createDirectory: FileManager.default.createDirectory(at:withIntermediateDirectories:attributes:),
    fileExists: FileManager.default.fileExists(atPath:)
  )
  public static let testValue = FileManagerClient()
}

extension DependencyValues {
  public var fileManagerClient: FileManagerClient {
    get { self[FileManagerClient.self] }
    set { self[FileManagerClient.self] = newValue }
  }
}
