import Dependencies
import DependenciesTestSupport
import Testing
@testable import RBKit

@MainActor
struct FzyJSClientTests {
  @Test(
    .dependencies {
      $0.fuzzyMatcher.score = { _, _ in .init(rank: 42, hasMatch: true) }
    }
  )
  func `fuzzyMatcher dependency should be overridable`() {
    @Dependency(\.fuzzyMatcher) var fuzzyMatcher
    let resolvedScore = fuzzyMatcher.score("amor", "app/models/order")

    #expect(resolvedScore.rank == 42)
    #expect(resolvedScore.hasMatch)
    #expect(resolvedScore.positions.isEmpty)
  }

  @Test
  func `fuzzyMatcher cache should compose primitive core api`() {
    let matcher = FzyJS.Cache()
    let candidate = "app/models/order"
    let score = matcher.score("amor", candidate)
    let expectedScore = FzyJS.rank("amor", candidate)

    #expect(score.rank == expectedScore.rank)
    #expect(score.hasMatch == expectedScore.hasMatch)
    #expect(score.positions == expectedScore.positions)
  }

  @Test
  func `fuzzyMatcher cache should return empty positions for no match`() {
    let score = FzyJS.Cache().score("obtv", "oaktextview.mm")

    #expect(score.rank == FzyJS.SCORE_MIN)
    #expect(!score.hasMatch)
    #expect(score.positions.isEmpty)
  }

  @Test
  func `fuzzyMatcher cache should guard primitive score with empty positions for equal length non match`() {
    let score = FzyJS.Cache().score("abc", "xyz")

    #expect(score.rank == FzyJS.SCORE_MIN)
    #expect(!score.hasMatch)
    #expect(score.positions.isEmpty)
  }

  @Test
  func `fuzzyMatcher cache should keep latest entries`() {
    let matcher = FzyJS.Cache(cacheLimit: 3)

    _ = matcher.score("a", "a1")
    _ = matcher.score("a", "a2")
    _ = matcher.score("a", "a3")
    _ = matcher.score("a", "a4")

    let cacheKeys = matcher.cacheKeys

    #expect(cacheKeys.count == 3)
    #expect(cacheKeys.map(\.candidate) == ["a2", "a3", "a4"])
  }

  @Test
  func `fuzzyMatcher cache should refresh recency on hit`() {
    let matcher = FzyJS.Cache(cacheLimit: 3)

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
