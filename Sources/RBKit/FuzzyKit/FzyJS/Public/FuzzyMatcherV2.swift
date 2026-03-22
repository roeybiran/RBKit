public actor FuzzyMatcherV2 {

  // MARK: Lifecycle

  public init() {
    cacheLimit = 50_000
  }

  init(cacheLimit: Int) {
    self.cacheLimit = cacheLimit
  }

  // MARK: Public

  public func score(_ filter: String, _ candidate: String) -> ScoreV2 {
    let cacheKey = CacheKey(filter: filter, candidate: candidate)
    if let cached = scoreCache[cacheKey] {
      if let index = cacheKeys.firstIndex(of: cacheKey) {
        cacheKeys.remove(at: index)
        cacheKeys.append(cacheKey)
      }
      return cached
    }

    let score: ScoreV2
    if !FuzzyMatcherV2Core.hasMatch(filter, candidate) {
      score = ScoreV2(rank: FuzzyMatcherV2Core.SCORE_MIN, hasMatch: false)
    } else {
      let n = filter.count
      let m = candidate.count

      // Mirror fzy's edge cases, then backtrack the winning path into Swift-native ranges.
      if n == 0 || m == 0 {
        score = ScoreV2(rank: FuzzyMatcherV2Core.SCORE_MIN, hasMatch: true)
      } else if n == m {
        score = ScoreV2(
          rank: FuzzyMatcherV2Core.SCORE_MAX,
          ranges: [candidate.startIndex ..< candidate.endIndex],
          hasMatch: true,
        )
      } else if m > 1024 {
        score = ScoreV2(rank: FuzzyMatcherV2Core.SCORE_MIN, hasMatch: true)
      } else {
        let haystackIndices = Array(candidate.indices)
        var D = [[Double]](
          repeating: [Double](repeating: FuzzyMatcherV2Core.SCORE_MIN, count: m),
          count: n
        )
        var M = [[Double]](
          repeating: [Double](repeating: FuzzyMatcherV2Core.SCORE_MIN, count: m),
          count: n
        )

        FuzzyMatcherV2Core.compute(filter, candidate, &D, &M)

        var matchRequired = false
        var haystackIndex = m - 1
        var currentLowerBound: String.Index?
        var currentUpperBound: String.Index?
        var reversedRanges = [Range<String.Index>]()

        for needleIndex in stride(from: n - 1, through: 0, by: -1) {
          while haystackIndex >= 0 {
            if
              D[needleIndex][haystackIndex] != FuzzyMatcherV2Core.SCORE_MIN,

              matchRequired
              || D[needleIndex][haystackIndex] == M[needleIndex][haystackIndex]

            {
              matchRequired = needleIndex > 0
                && haystackIndex > 0
                && M[needleIndex][haystackIndex]
                == D[needleIndex - 1][haystackIndex - 1] + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE
              let matchedIndex = haystackIndices[haystackIndex]
              let matchedUpperBound = candidate.index(after: matchedIndex)

              if currentLowerBound == matchedUpperBound {
                currentLowerBound = matchedIndex
              } else {
                if let currentLowerBound, let currentUpperBound {
                  reversedRanges.append(currentLowerBound ..< currentUpperBound)
                }
                currentLowerBound = matchedIndex
                currentUpperBound = matchedUpperBound
              }

              haystackIndex -= 1
              break
            }

            haystackIndex -= 1
          }
        }

        if let currentLowerBound, let currentUpperBound {
          reversedRanges.append(currentLowerBound ..< currentUpperBound)
        }

        score = ScoreV2(
          rank: M[n - 1][m - 1],
          ranges: reversedRanges.reversed(),
          hasMatch: true,
        )
      }
    }

    if scoreCache.count >= cacheLimit, let oldestCacheKey = cacheKeys.first {
      scoreCache.removeValue(forKey: oldestCacheKey)
      cacheKeys.removeFirst()
    }
    scoreCache[cacheKey] = score
    cacheKeys.append(cacheKey)

    return score
  }

  // MARK: Internal

  var cacheEntryCount: Int {
    scoreCache.count
  }

  var cachedCandidates: [String] {
    cacheKeys.map(\.candidate)
  }

  // MARK: Private

  private struct CacheKey: Hashable {
    let filter: String
    let candidate: String
  }

  private let cacheLimit: Int
  private var cacheKeys = [CacheKey]()
  private var scoreCache: [CacheKey: ScoreV2] = [:]
}
