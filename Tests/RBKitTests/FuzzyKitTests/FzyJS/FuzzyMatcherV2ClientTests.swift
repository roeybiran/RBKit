import Dependencies
import Testing
@testable import RBKit

struct FuzzyMatcherV2ClientTests {
  @Test
  func `fuzzyMatcherV2 dependency should be overridable`() async {
    let expectedScore = ScoreV2(rank: 42, hasMatch: true)

    let resolvedScore = await withDependencies {
      $0.fuzzyMatcherV2.score = { _, _ in expectedScore }
    } operation: {
      @Dependency(\.fuzzyMatcherV2) var fuzzyMatcherV2
      return await fuzzyMatcherV2.score("amor", "app/models/order")
    }

    #expect(resolvedScore.rank == expectedScore.rank)
    #expect(resolvedScore.hasMatch == expectedScore.hasMatch)
    #expect(resolvedScore.ranges.count == expectedScore.ranges.count)
  }

  @Test
  func `fuzzyMatcherV2 should compose primitive core api`() async {
    let matcher = FuzzyMatcherV2()
    let candidate = "app/models/order"
    let score = await matcher.score("amor", candidate)

    #expect(score.rank == FuzzyMatcherV2Core.score("amor", "app/models/order"))
    #expect(score.hasMatch == FuzzyMatcherV2Core.hasMatch("amor", "app/models/order"))
    let firstRange: Range<String.Index> = score.ranges[0]
    #expect(String(candidate[firstRange]) == "a")
    #expect(score.ranges.map { String(candidate[$0]) } == ["a", "m", "or"])
  }

  @Test
  func `fuzzyMatcherV2 should return empty ranges for no match`() async {
    let score = await FuzzyMatcherV2().score("obtv", "oaktextview.mm")

    #expect(score.rank == FuzzyMatcherV2Core.SCORE_MIN)
    #expect(!score.hasMatch)
    #expect(score.ranges.isEmpty)
  }

  @Test
  func `fuzzyMatcherV2 should guard primitive score for equal length non match`() async {
    let score = await FuzzyMatcherV2().score("abc", "xyz")

    #expect(score.rank == FuzzyMatcherV2Core.SCORE_MIN)
    #expect(!score.hasMatch)
    #expect(score.ranges.isEmpty)
  }

  @Test
  func `fuzzyMatcherV2 cache should keep latest entries`() async {
    let matcher = FuzzyMatcherV2(cacheLimit: 3)

    _ = await matcher.score("a", "a1")
    _ = await matcher.score("a", "a2")
    _ = await matcher.score("a", "a3")
    _ = await matcher.score("a", "a4")

    #expect(await matcher.cacheEntryCount == 3)
    #expect(await matcher.cachedCandidates == ["a2", "a3", "a4"])
  }
}
