import Dependencies
import DependenciesMacros

// MARK: - RandomNumberClient

@DependencyClient
public struct RandomNumberClient {
  public var generate: (_ range: Range<Double>) -> Double = { _ in .zero }
}

// MARK: DependencyKey

extension RandomNumberClient: DependencyKey {
  public static let liveValue = Self(generate: Double.random)
  public static let testValue = Self()
}

extension DependencyValues {
  public var randomNumber: RandomNumberClient {
    get { self[RandomNumberClient.self] }
    set { self[RandomNumberClient.self] = newValue }
  }
}
