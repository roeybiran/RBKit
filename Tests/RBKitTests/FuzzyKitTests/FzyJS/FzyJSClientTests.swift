import Dependencies
import Testing
@testable import RBKit

struct FzyJSClientTests {
  @Test
  func `fuzzyMatcher dependency should be overridable`() async {
    let expectedScore = FzyJS.Rank(rank: 42, hasMatch: true)

    let resolvedScore = await withDependencies {
      $0.fuzzyMatcher.score = { _, _ in expectedScore }
    } operation: {
      @Dependency(\.fuzzyMatcher) var fuzzyMatcher
      return await fuzzyMatcher.score("amor", "app/models/order")
    }

    #expect(resolvedScore.rank == expectedScore.rank)
    #expect(resolvedScore.hasMatch == expectedScore.hasMatch)
    #expect(resolvedScore.positions.count == expectedScore.positions.count)
  }

  @Test
  func `fuzzyMatcher cache should compose primitive core api`() async {
    let matcher = FzyJS.Cache()
    let candidate = "app/models/order"
    let score = await matcher.score("amor", candidate)
    let expectedScore = FzyJS.rank("amor", candidate)

    #expect(score.rank == expectedScore.rank)
    #expect(score.hasMatch == expectedScore.hasMatch)
    #expect(score.positions == expectedScore.positions)
  }

  @Test
  func `fuzzyMatcher cache should return empty positions for no match`() async {
    let score = await FzyJS.Cache().score("obtv", "oaktextview.mm")

    #expect(score.rank == FzyJS.SCORE_MIN)
    #expect(!score.hasMatch)
    #expect(score.positions.isEmpty)
  }

  @Test
  func `fuzzyMatcher cache should guard primitive score with empty positions for equal length non match`() async {
    let score = await FzyJS.Cache().score("abc", "xyz")

    #expect(score.rank == FzyJS.SCORE_MIN)
    #expect(!score.hasMatch)
    #expect(score.positions.isEmpty)
  }

  @Test
  func `fuzzyMatcher cache should keep latest entries`() async {
    let matcher = FzyJS.Cache(cacheLimit: 3)

    _ = await matcher.score("a", "a1")
    _ = await matcher.score("a", "a2")
    _ = await matcher.score("a", "a3")
    _ = await matcher.score("a", "a4")

    let cacheKeys = await matcher.cacheKeys

    #expect(cacheKeys.count == 3)
    #expect(cacheKeys.map(\.candidate) == ["a2", "a3", "a4"])
  }

  @Test
  func `fuzzyMatcher cache should refresh recency on hit`() async {
    let matcher = FzyJS.Cache(cacheLimit: 3)

    _ = await matcher.score("a", "a1")
    _ = await matcher.score("a", "a2")
    _ = await matcher.score("a", "a3")
    _ = await matcher.score("a", "a1")
    _ = await matcher.score("a", "a4")

    let cacheKeys = await matcher.cacheKeys

    #expect(cacheKeys.count == 3)
    #expect(cacheKeys.map(\.candidate) == ["a3", "a1", "a4"])
  }
}
