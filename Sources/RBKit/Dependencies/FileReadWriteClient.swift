import Dependencies
import Foundation

// MARK: - FileReadWriteClient

public struct FileReadWriteClient {
  public var read: (_ url: URL) throws -> Data
  public var write: (_ data: Data, _ url: URL, _ opts: Data.WritingOptions) throws -> Void
}

// MARK: DependencyKey

extension FileReadWriteClient: DependencyKey {
  public static let liveValue = FileReadWriteClient(
    read: { try Data(contentsOf: $0) },
    write: { data, url, opts in try data.write(to: url, options: opts) })

  #if DEBUG
  public static let testValue = FileReadWriteClient(
    read: unimplemented("FileClient.read"),
    write: unimplemented("FileClient.write"))

  public static let placeholder = FileReadWriteClient(
    read: { _ in Data() },
    write: { _, _, _ in })
  #endif
}

extension DependencyValues {
  public var fileClient: FileReadWriteClient {
    get { self[FileReadWriteClient.self] }
    set { self[FileReadWriteClient.self] = newValue }
  }
}
