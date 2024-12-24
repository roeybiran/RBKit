import Dependencies
import DependenciesMacros

// MARK: - RandomNumberClient

@DependencyClient
public struct RandomNumberClient: Sendable {
  public var generate: @Sendable (_ range: Range<Double>) -> Double = { _ in .zero }
}

// MARK: DependencyKey

extension RandomNumberClient: DependencyKey {
  public static let liveValue = Self(
    generate: { Double.random(in: $0) })
  public static let testValue = Self()
}

extension DependencyValues {
  public var randomNumber: RandomNumberClient {
    get { self[RandomNumberClient.self] }
    set { self[RandomNumberClient.self] = newValue }
  }
}
