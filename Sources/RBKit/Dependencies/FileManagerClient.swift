import Dependencies
import DependenciesMacros
import Foundation

// MARK: - FileManagerClient

@DependencyClient
public struct FileManagerClient {
  public var urls: (
    _ directory: FileManager.SearchPathDirectory,
    _ domainMask: FileManager.SearchPathDomainMask
  ) -> [URL] = { _, _ in [] }
  public var createDirectory: (
    _ atURL: URL,
    _ withIntermediateDirectories: Bool,
    _ attributes: [FileAttributeKey: Any]?
  ) throws
    -> Void
}

// MARK: DependencyKey

extension FileManagerClient: DependencyKey {
  public static let liveValue = FileManagerClient(
    urls: FileManager.default.urls,
    createDirectory: FileManager.default.createDirectory(at:withIntermediateDirectories:attributes:)
  )
  public static let testValue = FileManagerClient()
}

extension DependencyValues {
  public var fileManagerClient: FileManagerClient {
    get { self[FileManagerClient.self] }
    set { self[FileManagerClient.self] = newValue }
  }
}
