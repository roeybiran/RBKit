import Dependencies
import Foundation

// MARK: - FileReadWriteClient

public struct DiskClient {
  public var read: (_ url: URL) throws -> Data
  public var write: (_ data: Data, _ url: URL, _ opts: Data.WritingOptions) throws -> Void
}

// MARK: DependencyKey

extension DiskClient: DependencyKey {
  public static let liveValue = DiskClient(
    read: { try Data(contentsOf: $0) },
    write: { data, url, opts in try data.write(to: url, options: opts) })

  #if DEBUG
  public static let testValue = DiskClient(
    read: unimplemented("FileClient.read"),
    write: unimplemented("FileClient.write"))

  public static let placeholder = DiskClient(
    read: { _ in Data() },
    write: { _, _, _ in })
  #endif
}

extension DependencyValues {
  public var fileClient: DiskClient {
    get { self[DiskClient.self] }
    set { self[DiskClient.self] = newValue }
  }
}
