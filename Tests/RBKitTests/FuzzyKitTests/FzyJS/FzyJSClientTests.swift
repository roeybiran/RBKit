import Dependencies
import DependenciesTestSupport
import Testing
@testable import RBKit

@MainActor
struct FzyJSClientTests {
  @Test(
    .dependencies {
      $0.fzyJS.score = { _, _ in 42 }
      $0.fzyJS.ranges = { _, candidate in
        [candidate.startIndex ..< candidate.index(after: candidate.startIndex)]
      }
    }
  )
  func `fzyJS dependency should be overridable`() {
    @Dependency(\.fzyJS) var fzyJS
    let resolvedScore = fzyJS.score("amor", "app/models/order")
    let resolvedRanges = fzyJS.ranges("amor", "app/models/order")

    #expect(resolvedScore == 42)
    #expect(resolvedRanges.count == 1)
  }

  @Test
  func `fzyJS service should compose primitive core api`() {
    let matcher = FzyJSService()
    let candidate = "app/models/order"
    let score = matcher.score("amor", candidate)

    #expect(score == FzyJS.score("amor", candidate))
    #expect(matcher.ranges("amor", candidate).map(\.lowerBound) == FzyJS.positions("amor", candidate))
  }

  @Test
  func `fzyJS service should return empty ranges for no match`() {
    let matcher = FzyJSService()
    let score = matcher.score("obtv", "oaktextview.mm")

    #expect(score == FzyJS.SCORE_MIN)
    #expect(matcher.ranges("obtv", "oaktextview.mm").isEmpty)
  }

  @Test
  func `fzyJS service should guard primitive score with empty ranges for equal length non match`() {
    let matcher = FzyJSService()
    let score = matcher.score("abc", "xyz")

    #expect(score == FzyJS.SCORE_MIN)
    #expect(matcher.ranges("abc", "xyz").isEmpty)
  }

  @Test
  func `fzyJS service cache should keep latest entries`() {
    let matcher = FzyJSService(cacheLimit: 3)

    _ = matcher.score("a", "a1")
    _ = matcher.score("a", "a2")
    _ = matcher.score("a", "a3")
    _ = matcher.score("a", "a4")

    let cacheKeys = matcher.cacheKeys

    #expect(cacheKeys.count == 3)
    #expect(cacheKeys.map(\.candidate) == ["a2", "a3", "a4"])
  }

  @Test
  func `fzyJS service cache should refresh recency on hit`() {
    let matcher = FzyJSService(cacheLimit: 3)

    _ = matcher.score("a", "a1")
    _ = matcher.score("a", "a2")
    _ = matcher.score("a", "a3")
    _ = matcher.score("a", "a1")
    _ = matcher.score("a", "a4")

    let cacheKeys = matcher.cacheKeys

    #expect(cacheKeys.count == 3)
    #expect(cacheKeys.map(\.candidate) == ["a3", "a1", "a4"])
  }
}
