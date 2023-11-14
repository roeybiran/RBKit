import Dependencies
import Foundation

// MARK: - FileReadWriteClient

public struct DiskClient {
  public var read: (_ sourceURL: URL) throws -> Data
  public var write: (_ data: Data, _ destinationURL: URL, _ options: Data.WritingOptions) throws -> Void
}

// MARK: DependencyKey

extension DiskClient: DependencyKey {
  public static let liveValue = DiskClient(
    read: { try Data(contentsOf: $0) },
    write: { data, destinationURL, options in try data.write(to: destinationURL, options: options) })

  #if DEBUG
  public static let testValue = DiskClient(
    read: unimplemented("FileClient.read"),
    write: unimplemented("FileClient.write"))
  #endif
}

extension DependencyValues {
  public var diskClient: DiskClient {
    get { self[DiskClient.self] }
    set { self[DiskClient.self] = newValue }
  }
}
