import Dependencies

// MARK: - RandomNumberClient

public struct RandomNumberClient {
  public var generate: (_ range: Range<Double>) -> Double
}

// MARK: DependencyKey

extension RandomNumberClient: DependencyKey {
  public static let liveValue = Self(generate: Double.random)

  #if DEBUG
  public static let testValue = Self(generate: { _ in 999 })
  #endif
}

extension DependencyValues {
  public var randomNumber: RandomNumberClient {
    get { self[RandomNumberClient.self] }
    set { self[RandomNumberClient.self] = newValue }
  }
}
