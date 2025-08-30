import Dependencies
import DependenciesMacros
import Foundation

// MARK: - DiskClient

@DependencyClient
public struct DiskClient: Sendable {
  public var read: @Sendable (_ sourceURL: URL) throws -> Data
  public var write:
    @Sendable (_ data: Data, _ destinationURL: URL, _ options: Data.WritingOptions) throws -> Void
}

// MARK: DependencyKey

extension DiskClient: DependencyKey {
  public static let liveValue = DiskClient(
    read: { try Data(contentsOf: $0) },
    write: { data, destinationURL, options in try data.write(to: destinationURL, options: options) }
  )

  public static let testValue = DiskClient()
}

extension DependencyValues {
  public var diskClient: DiskClient {
    get { self[DiskClient.self] }
    set { self[DiskClient.self] = newValue }
  }
}
