import Dependencies
import DependenciesMacros
import Foundation

// MARK: - URLClient

@DependencyClient
public struct URLClient {
  public var resourceValues: (_ url: URL, _ keys: Set<URLResourceKey>) throws -> URLResourceValuesWrapper = { _, _ in .init() }
}

// MARK: DependencyKey

extension URLClient: DependencyKey {
  public static let liveValue: Self = .init(resourceValues: { url, keys in .init(try url.resourceValues(forKeys: keys)) })

  public static let testValue = Self()
}

extension DependencyValues {
  public var urlClient: URLClient {
    get { self[URLClient.self] }
    set { self[URLClient.self] = newValue }
  }
}
