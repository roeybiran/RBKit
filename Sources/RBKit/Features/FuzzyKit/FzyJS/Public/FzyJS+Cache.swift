extension FzyJS {
  public actor Cache {

    // MARK: Lifecycle

    public init(cacheLimit: Int = 50_000) {
      self.cacheLimit = cacheLimit
    }

    // MARK: Public

    public func score(_ filter: String, _ candidate: String) -> Rank {
      let cacheKey = CacheKey(filter: filter, candidate: candidate)
      if let cached = scoreCache[cacheKey] {
        if let index = cacheKeys.firstIndex(of: cacheKey) {
          cacheKeys.remove(at: index)
          cacheKeys.append(cacheKey)
        }
        return cached
      }

      let rank = FzyJS.rank(filter, candidate)

      if scoreCache.count >= cacheLimit, let oldestCacheKey = cacheKeys.first {
        scoreCache.removeValue(forKey: oldestCacheKey)
        cacheKeys.removeFirst()
      }
      scoreCache[cacheKey] = rank
      cacheKeys.append(cacheKey)

      return rank
    }

    // MARK: Internal

    struct CacheKey: Hashable {
      let filter: String
      let candidate: String
    }

    var cacheKeys = [CacheKey]()

    // MARK: Private

    private let cacheLimit: Int
    private var scoreCache = [CacheKey: Rank]()
  }
}
