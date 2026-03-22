import Dependencies

// MARK: - FuzzyMatcherV2Client

public struct FuzzyMatcherV2Client: Sendable {
  public init(
    score: @escaping @Sendable (_ filter: String, _ candidate: String) async -> ScoreV2 = { _, _ in
      ScoreV2(rank: FuzzyMatcherV2Core.SCORE_MIN, hasMatch: false)
    }
  ) {
    self.score = score
  }

  public var score: @Sendable (_ filter: String, _ candidate: String) async -> ScoreV2
}

// MARK: DependencyKey

extension FuzzyMatcherV2Client: DependencyKey {
  public static let liveValue: Self = {
    let fuzzyMatcherV2 = FuzzyMatcherV2()
    return Self(
      score: { filter, candidate in
        await fuzzyMatcherV2.score(filter, candidate)
      }
    )
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var fuzzyMatcherV2: FuzzyMatcherV2Client {
    get { self[FuzzyMatcherV2Client.self] }
    set { self[FuzzyMatcherV2Client.self] = newValue }
  }
}
