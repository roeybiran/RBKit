import Dependencies
import DependenciesMacros

// MARK: - FzyJSClient

@DependencyClient
public struct FzyJSClient: Sendable {
  public var score: @Sendable @MainActor (_ filter: String, _ candidate: String) -> Double = { _, _ in 0 }
  public var ranges: @Sendable @MainActor (_ filter: String, _ candidate: String) -> [Range<String.Index>] = { _, _ in [] }
}

// MARK: DependencyKey

extension FzyJSClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    score: { filter, candidate in
      fzyJSService.score(filter, candidate)
    },
    ranges: { filter, candidate in
      fzyJSService.ranges(filter, candidate)
    },
  )

  public static let testValue = Self()

  // MARK: Internal

  @MainActor static let fzyJSService = FzyJSService()

}

extension DependencyValues {
  public var fzyJS: FzyJSClient {
    get { self[FzyJSClient.self] }
    set { self[FzyJSClient.self] = newValue }
  }
}
