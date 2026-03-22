public struct ScoreV2: Sendable {
  public init(
    rank: Double,
    ranges: [Range<String.Index>] = [],
    hasMatch: Bool,
  ) {
    self.rank = rank
    self.ranges = ranges
    self.hasMatch = hasMatch
  }

  public let rank: Double
  public let ranges: [Range<String.Index>]
  public let hasMatch: Bool
}
