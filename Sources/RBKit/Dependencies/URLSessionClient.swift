import Dependencies
import DependenciesMacros
import Foundation

// MARK: - URLSessionClient

@DependencyClient
public struct URLSessionClient: Sendable {
  public var data: @Sendable (_ request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: DependencyKey

extension URLSessionClient: DependencyKey {
  public static let liveValue = Self(
    data: { try await URLSession.shared.data(for: $0) }
  )
  public static let testValue = Self()
}

extension DependencyValues {
  public var urlSessionClient: URLSessionClient {
    get { self[URLSessionClient.self] }
    set { self[URLSessionClient.self] = newValue }
  }
}
