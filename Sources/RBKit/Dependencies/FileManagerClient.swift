import Dependencies
import Foundation

// MARK: - FileManagerClient

public struct FileManagerClient {
  public var urls: (_ directory: FileManager.SearchPathDirectory, _ domainMask: FileManager.SearchPathDomainMask) -> [URL]
  public var createDirectory: (_ atURL: URL, _ withIntermediateDirectories: Bool, _ attributes: [FileAttributeKey: Any]?) throws
    -> Void
}

// MARK: DependencyKey

extension FileManagerClient: DependencyKey {
  public static let liveValue = FileManagerClient(
    urls: FileManager.default.urls,
    createDirectory: FileManager.default.createDirectory(at:withIntermediateDirectories:attributes:))

  #if DEBUG
  public static let testValue = FileManagerClient(
    urls: unimplemented("FileManagerClient.urls"),
    createDirectory: unimplemented("FileManagerClient.createDirectory"))

  public static let placeholder = FileManagerClient(
    urls: { _, _ in [URL(fileURLWithPath: "/HOME/APP_SUPPORT/", isDirectory: true)] },
    createDirectory: { _, _, _ in })
  #endif
}

extension DependencyValues {
  public var fileManagerClient: FileManagerClient {
    get { self[FileManagerClient.self] }
    set { self[FileManagerClient.self] = newValue }
  }
}
