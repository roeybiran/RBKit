import Dependencies
import DependenciesMacros

// MARK: - FzyJSClient

@DependencyClient
public struct FzyJSClient: Sendable {
  public var score: @Sendable (_ filter: String, _ candidate: String) async -> FzyJS.Rank = { _, _ in .init() }
}

// MARK: DependencyKey

extension FzyJSClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    score: { filter, candidate in
      await fzyJSCache.score(filter, candidate)
    }
  )

  public static let testValue = Self()

  // MARK: Internal

  static let fzyJSCache = FzyJS.Cache()

}

extension DependencyValues {
  public var fuzzyMatcher: FzyJSClient {
    get { self[FzyJSClient.self] }
    set { self[FzyJSClient.self] = newValue }
  }
}
