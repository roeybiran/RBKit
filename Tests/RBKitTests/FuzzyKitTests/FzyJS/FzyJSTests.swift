import Testing
@testable import RBKit

// Parity tests ported from fzy.js: https://github.com/jhawthorn/fzy.js/blob/main/test.js

private let epsilon = 0.000_000_1

// MARK: - FzyJSTests

struct FzyJSTests {
  @Test
  func `should prefer starts of words`() {
    #expect(
      FzyJS.score("amor", "app/models/order")
        > FzyJS.score("amor", "app/models/zrder")
    )
  }

  @Test
  func `should prefer consecutive letters`() {
    #expect(
      FzyJS.score("amo", "app/models/foo")
        > FzyJS.score("amo", "app/m/foo")
    )
  }

  @Test
  func `should prefer contiguous over letter following period`() {
    #expect(
      FzyJS.score("gemfil", "Gemfile.lock")
        < FzyJS.score("gemfil", "Gemfile")
    )
  }

  @Test
  func `should prefer shorter matches`() {
    #expect(
      FzyJS.score("abce", "abcdef")
        > FzyJS.score("abce", "abc de")
    )
    #expect(
      FzyJS.score("abc", "    a b c ")
        > FzyJS.score("abc", " a  b  c ")
    )
    #expect(
      FzyJS.score("abc", " a b c    ")
        > FzyJS.score("abc", " a  b  c ")
    )
  }

  @Test
  func `should prefer shorter candidates`() {
    #expect(
      FzyJS.score("test", "tests")
        > FzyJS.score("test", "testing")
    )
  }

  @Test
  func `should prefer start of candidate`() {
    #expect(
      FzyJS.score("test", "testing")
        > FzyJS.score("test", "/testing")
    )
  }

  @Test
  func `score exact score`() {
    #expect(FzyJS.score("abc", "abc") == FzyJS.SCORE_MAX)
    #expect(FzyJS.score("aBc", "abC") == FzyJS.SCORE_MAX)
  }

  @Test
  func `score empty query`() {
    #expect(FzyJS.score("", "") == FzyJS.SCORE_MIN)
    #expect(FzyJS.score("", "a") == FzyJS.SCORE_MIN)
    #expect(FzyJS.score("", "bb") == FzyJS.SCORE_MIN)
  }

  @Test
  func `score gaps`() {
    #expect(abs(FzyJS.score("a", "*a") - FzyJS.SCORE_GAP_LEADING) < epsilon)
    #expect(abs(FzyJS.score("a", "*ba") - FzyJS.SCORE_GAP_LEADING * 2) < epsilon)
    #expect(abs(FzyJS.score("a", "**a*") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_GAP_TRAILING)) < epsilon)
    #expect(abs(FzyJS.score("a", "**a**") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_GAP_TRAILING * 2)) < epsilon)
    #expect(abs(FzyJS
        .score("aa", "**aa**") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_MATCH_CONSECUTIVE + FzyJS.SCORE_GAP_TRAILING * 2)) <
      epsilon)
    #expect(abs(FzyJS
        .score("aa", "**a*a**") -
        (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_GAP_INNER + FzyJS.SCORE_GAP_TRAILING + FzyJS
          .SCORE_GAP_TRAILING)) < epsilon)
  }

  @Test
  func `score consecutive`() {
    #expect(abs(FzyJS.score("aa", "*aa") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_MATCH_CONSECUTIVE)) < epsilon)
    #expect(abs(FzyJS.score("aaa", "*aaa") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_MATCH_CONSECUTIVE * 2)) < epsilon)
    #expect(abs(FzyJS.score("aaa", "*a*aa") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_GAP_INNER + FzyJS.SCORE_MATCH_CONSECUTIVE)) <
      epsilon)
  }

  @Test
  func `score slash`() {
    #expect(abs(FzyJS.score("a", "/a") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_MATCH_SLASH)) < epsilon)
    #expect(abs(FzyJS.score("a", "*/a") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_MATCH_SLASH)) < epsilon)
    #expect(abs(FzyJS
        .score("aa", "a/aa") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_MATCH_SLASH + FzyJS.SCORE_MATCH_CONSECUTIVE)) < epsilon)
  }

  @Test
  func `score capital`() {
    #expect(abs(FzyJS.score("a", "bA") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_MATCH_CAPITAL)) < epsilon)
    #expect(abs(FzyJS.score("a", "baA") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_MATCH_CAPITAL)) < epsilon)
    #expect(abs(FzyJS
        .score("aa", "baAa") - (FzyJS.SCORE_GAP_LEADING * 2 + FzyJS.SCORE_MATCH_CAPITAL + FzyJS.SCORE_MATCH_CONSECUTIVE)) <
      epsilon)
  }

  @Test
  func `score dot`() {
    #expect(abs(FzyJS.score("a", ".a") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_MATCH_DOT)) < epsilon)
    #expect(abs(FzyJS.score("a", "*a.a") - (FzyJS.SCORE_GAP_LEADING * 3 + FzyJS.SCORE_MATCH_DOT)) < epsilon)
    #expect(abs(FzyJS.score("a", "*a.a") - (FzyJS.SCORE_GAP_LEADING + FzyJS.SCORE_GAP_INNER + FzyJS.SCORE_MATCH_DOT)) < epsilon)
  }

  @Test
  func `positions consecutive`() {
    let candidate = "app/models/foo"

    #expect(
      FzyJS.positions("amo", candidate)
        == [0, 4, 5].map { candidate.index(candidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions start of word`() {
    let candidate = "app/models/order"

    #expect(
      FzyJS.positions("amor", candidate)
        == [0, 4, 11, 12].map { candidate.index(candidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions no bonuses`() {
    let firstCandidate = "tags"
    let secondCandidate = "examples.txt"

    #expect(
      FzyJS.positions("as", firstCandidate)
        == [1, 3].map { firstCandidate.index(firstCandidate.startIndex, offsetBy: $0) }
    )
    #expect(
      FzyJS.positions("as", secondCandidate)
        == [2, 7].map { secondCandidate.index(secondCandidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions multiple candidates start of words`() {
    let candidate = "a/a/b/c/c"

    #expect(
      FzyJS.positions("abc", candidate)
        == [2, 4, 6].map { candidate.index(candidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions exact match`() {
    let candidate = "foo"

    #expect(FzyJS.positions("foo", candidate) == Array(candidate.indices))
  }

  @Test
  func `rank composes the public fzy api into positions`() {
    let candidate = "app/models/order"
    let rank = FzyJS.rank("amor", candidate)

    #expect(rank.rank == FzyJS.score("amor", candidate))
    #expect(rank.hasMatch == FzyJS.hasMatch("amor", candidate))
    #expect(rank.positions == FzyJS.positions("amor", candidate))
  }

  @Test
  func `rank guards the equal length primitive edge case`() {
    let rank = FzyJS.rank("abc", "xyz")

    #expect(FzyJS.score("abc", "xyz") == FzyJS.SCORE_MAX)
    #expect(!rank.hasMatch)
    #expect(rank.rank == FzyJS.SCORE_MIN)
    #expect(rank.positions.isEmpty)
  }

  @Test
  func `hasMatch follows subsequence semantics`() {
    #expect(FzyJS.hasMatch("amo", "app/models/foo"))
    #expect(!FzyJS.hasMatch("obtv", "oaktextview.mm"))
  }

  @Test
  func `no subsequence match should return negative infinity`() {
    #expect(FzyJS.score("obtv", "oaktextview.mm") == FzyJS.SCORE_MIN)
    #expect(!FzyJS.hasMatch("obtv", "oaktextview.mm"))
  }
}
