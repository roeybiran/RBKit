import Dependencies
import DependenciesMacros
import Foundation

// MARK: - URLSessionClient

@DependencyClient
public struct URLSessionClient {
  public var data: (_ request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: DependencyKey

extension URLSessionClient: DependencyKey {
  public static let liveValue: Self = .init(data: URLSession.shared.data)
  public static let testValue = Self()
}

extension DependencyValues {
  public var urlSessionClient: URLSessionClient {
    get { self[URLSessionClient.self] }
    set { self[URLSessionClient.self] = newValue }
  }
}
