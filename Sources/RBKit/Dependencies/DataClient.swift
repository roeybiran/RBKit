import Dependencies
import DependenciesMacros
import Foundation

// MARK: - DataClient

@DependencyClient
public struct DataClient: Sendable {
  public var contentsOfURL: @Sendable (_ url: URL) throws -> Data
}

// MARK: DependencyKey

extension DataClient: DependencyKey {
  public static let liveValue = Self(
    contentsOfURL: { try Data(contentsOf: $0) }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var dataClient: DataClient {
    get { self[DataClient.self] }
    set { self[DataClient.self] = newValue }
  }
}

