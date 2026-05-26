@MainActor
public final class FzyJSService {

  // MARK: Lifecycle

  public init(cacheLimit: Int = 50_000) {
    self.cacheLimit = cacheLimit
  }

  // MARK: Public

  public func score(_ filter: String, _ candidate: String) -> Double {
    let cacheKey = CacheKey(filter: filter, candidate: candidate)
    if let cached = cache[cacheKey]?.score {
      return cached
    }

    let score = FzyJS.hasMatch(filter, candidate)
      ? FzyJS.score(filter, candidate)
      : FzyJS.SCORE_MIN

    let isCached = cache[cacheKey] != nil
    if cache.count >= cacheLimit, !isCached, let oldestCacheKey = cacheKeys.first {
      cache.removeValue(forKey: oldestCacheKey)
      cacheKeys.removeFirst()
    }
    var entry = cache[cacheKey] ?? Entry()
    entry.score = score
    cache[cacheKey] = entry
    if !isCached {
      cacheKeys.append(cacheKey)
    }

    return score
  }

  public func ranges(_ filter: String, _ candidate: String) -> [Range<String.Index>] {
    let cacheKey = CacheKey(filter: filter, candidate: candidate)
    if let cached = cache[cacheKey]?.ranges {
      return cached
    }

    let ranges = FzyJS.hasMatch(filter, candidate)
      ? FzyJS.positions(filter, candidate).map { position in
        position ..< candidate.index(after: position)
      }
      : []

    let isCached = cache[cacheKey] != nil
    if cache.count >= cacheLimit, !isCached, let oldestCacheKey = cacheKeys.first {
      cache.removeValue(forKey: oldestCacheKey)
      cacheKeys.removeFirst()
    }
    var entry = cache[cacheKey] ?? Entry()
    entry.ranges = ranges
    cache[cacheKey] = entry
    if !isCached {
      cacheKeys.append(cacheKey)
    }

    return ranges
  }

  // MARK: Internal

  struct CacheKey: Hashable {
    let filter: String
    let candidate: String
  }

  var cacheKeys = [CacheKey]()

  // MARK: Private

  private struct Entry {
    var score: Double?
    var ranges: [Range<String.Index>]?
  }

  private let cacheLimit: Int
  private var cache = [CacheKey: Entry]()
}
