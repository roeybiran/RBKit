public struct Score: Hashable, Comparable {
  public init(rank: Double = 0, ranges: [Range<Int>] = []) {
    self.rank = rank
    self.ranges = ranges
  }

  public let rank: Double
  public let ranges: [Range<Int>]

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.rank == rhs.rank
  }

  public static func <(lhs: Self, rhs: Self) -> Bool {
    lhs.rank < rhs.rank
  }
}
