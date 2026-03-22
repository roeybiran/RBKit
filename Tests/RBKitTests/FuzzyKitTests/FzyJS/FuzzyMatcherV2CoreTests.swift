import Testing
@testable import RBKit

// Parity tests ported from fzy.js: https://github.com/jhawthorn/fzy.js/blob/main/test.js

private let epsilon = 0.000_000_1

struct FuzzyMatcherV2CoreTests {
  @Test
  func `should prefer starts of words`() {
    #expect(
      FuzzyMatcherV2Core.score("amor", "app/models/order")
        > FuzzyMatcherV2Core.score("amor", "app/models/zrder")
    )
  }

  @Test
  func `should prefer consecutive letters`() {
    #expect(
      FuzzyMatcherV2Core.score("amo", "app/models/foo")
        > FuzzyMatcherV2Core.score("amo", "app/m/foo")
    )
  }

  @Test
  func `should prefer contiguous over letter following period`() {
    #expect(
      FuzzyMatcherV2Core.score("gemfil", "Gemfile.lock")
        < FuzzyMatcherV2Core.score("gemfil", "Gemfile")
    )
  }

  @Test
  func `should prefer shorter matches`() {
    #expect(
      FuzzyMatcherV2Core.score("abce", "abcdef")
        > FuzzyMatcherV2Core.score("abce", "abc de")
    )
    #expect(
      FuzzyMatcherV2Core.score("abc", "    a b c ")
        > FuzzyMatcherV2Core.score("abc", " a  b  c ")
    )
    #expect(
      FuzzyMatcherV2Core.score("abc", " a b c    ")
        > FuzzyMatcherV2Core.score("abc", " a  b  c ")
    )
  }

  @Test
  func `should prefer shorter candidates`() {
    #expect(
      FuzzyMatcherV2Core.score("test", "tests")
        > FuzzyMatcherV2Core.score("test", "testing")
    )
  }

  @Test
  func `should prefer start of candidate`() {
    #expect(
      FuzzyMatcherV2Core.score("test", "testing")
        > FuzzyMatcherV2Core.score("test", "/testing")
    )
  }

  @Test
  func `score exact score`() {
    #expect(FuzzyMatcherV2Core.score("abc", "abc") == FuzzyMatcherV2Core.SCORE_MAX)
    #expect(FuzzyMatcherV2Core.score("aBc", "abC") == FuzzyMatcherV2Core.SCORE_MAX)
  }

  @Test
  func `score empty query`() {
    #expect(FuzzyMatcherV2Core.score("", "") == FuzzyMatcherV2Core.SCORE_MIN)
    #expect(FuzzyMatcherV2Core.score("", "a") == FuzzyMatcherV2Core.SCORE_MIN)
    #expect(FuzzyMatcherV2Core.score("", "bb") == FuzzyMatcherV2Core.SCORE_MIN)
  }

  @Test
  func `score gaps`() {
    #expect(abs(FuzzyMatcherV2Core.score("a", "*a") - FuzzyMatcherV2Core.SCORE_GAP_LEADING) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "*ba") - FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "**a*") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_GAP_TRAILING)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "**a**") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_GAP_TRAILING * 2)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("aa", "**aa**") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE + FuzzyMatcherV2Core.SCORE_GAP_TRAILING * 2)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("aa", "**a*a**") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_GAP_INNER + FuzzyMatcherV2Core.SCORE_GAP_TRAILING + FuzzyMatcherV2Core.SCORE_GAP_TRAILING)) < epsilon)
  }

  @Test
  func `score consecutive`() {
    #expect(abs(FuzzyMatcherV2Core.score("aa", "*aa") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("aaa", "*aaa") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE * 2)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("aaa", "*a*aa") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_GAP_INNER + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE)) < epsilon)
  }

  @Test
  func `score slash`() {
    #expect(abs(FuzzyMatcherV2Core.score("a", "/a") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_MATCH_SLASH)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "*/a") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_MATCH_SLASH)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("aa", "a/aa") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_MATCH_SLASH + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE)) < epsilon)
  }

  @Test
  func `score capital`() {
    #expect(abs(FuzzyMatcherV2Core.score("a", "bA") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_MATCH_CAPITAL)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "baA") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_MATCH_CAPITAL)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("aa", "baAa") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 2 + FuzzyMatcherV2Core.SCORE_MATCH_CAPITAL + FuzzyMatcherV2Core.SCORE_MATCH_CONSECUTIVE)) < epsilon)
  }

  @Test
  func `score dot`() {
    #expect(abs(FuzzyMatcherV2Core.score("a", ".a") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_MATCH_DOT)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "*a.a") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING * 3 + FuzzyMatcherV2Core.SCORE_MATCH_DOT)) < epsilon)
    #expect(abs(FuzzyMatcherV2Core.score("a", "*a.a") - (FuzzyMatcherV2Core.SCORE_GAP_LEADING + FuzzyMatcherV2Core.SCORE_GAP_INNER + FuzzyMatcherV2Core.SCORE_MATCH_DOT)) < epsilon)
  }

  @Test
  func `positions consecutive`() {
    #expect(FuzzyMatcherV2Core.positions("amo", "app/models/foo") == [0, 4, 5])
  }

  @Test
  func `positions start of word`() {
    #expect(FuzzyMatcherV2Core.positions("amor", "app/models/order") == [0, 4, 11, 12])
  }

  @Test
  func `positions no bonuses`() {
    #expect(FuzzyMatcherV2Core.positions("as", "tags") == [1, 3])
    #expect(FuzzyMatcherV2Core.positions("as", "examples.txt") == [2, 7])
  }

  @Test
  func `positions multiple candidates start of words`() {
    #expect(FuzzyMatcherV2Core.positions("abc", "a/a/b/c/c") == [2, 4, 6])
  }

  @Test
  func `positions exact match`() {
    #expect(FuzzyMatcherV2Core.positions("foo", "foo") == [0, 1, 2])
  }

  @Test
  func `hasMatch follows subsequence semantics`() {
    #expect(FuzzyMatcherV2Core.hasMatch("amo", "app/models/foo"))
    #expect(!FuzzyMatcherV2Core.hasMatch("obtv", "oaktextview.mm"))
  }

  @Test
  func `no subsequence match should return negative infinity`() {
    #expect(FuzzyMatcherV2Core.score("obtv", "oaktextview.mm") == FuzzyMatcherV2Core.SCORE_MIN)
    #expect(!FuzzyMatcherV2Core.hasMatch("obtv", "oaktextview.mm"))
  }
}
