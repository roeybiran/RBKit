import Dependencies
import DependenciesMacros
import Foundation

// MARK: - StringClient

@DependencyClient
public struct StringClient: Sendable {
  public var contentsOf: @Sendable (_ url: URL, _ encoding: String.Encoding) throws -> String
}

// MARK: DependencyKey

extension StringClient: DependencyKey {
  public static let liveValue = Self(
    contentsOf: { url, encoding in
      try String(contentsOf: url, encoding: encoding)
    }
  )

  public static let testValue = StringClient()
}

extension DependencyValues {
  public var stringClient: StringClient {
    get { self[StringClient.self] }
    set { self[StringClient.self] = newValue }
  }
}
