extension FzyJS {
  public struct Rank: Sendable {
    public init(
      rank: Double = 0,
      positions: [String.Index] = [],
      hasMatch: Bool = false,
    ) {
      self.rank = rank
      self.positions = positions
      self.hasMatch = hasMatch
    }

    public let rank: Double
    public let positions: [String.Index]
    public let hasMatch: Bool
  }

  /// RBKit's high-level API built on the parity-preserving fzy.js primitives.
  public static func rank(_ needle: String, _ haystack: String) -> Rank {
    let hasMatch = hasMatch(needle, haystack)
    guard hasMatch else {
      return Rank(rank: SCORE_MIN, hasMatch: false)
    }

    return Rank(
      rank: score(needle, haystack),
      positions: positions(needle, haystack),
      hasMatch: true,
    )
  }
}
