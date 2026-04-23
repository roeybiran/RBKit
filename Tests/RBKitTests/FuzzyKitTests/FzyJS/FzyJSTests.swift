import Testing
@testable import RBKit

// Parity tests ported from fzy.js: https://github.com/jhawthorn/fzy.js/blob/main/test.js

private let floatingPointTolerance = 0.000_000_1
private let SCORE_MIN = FzyJS.SCORE_MIN
private let SCORE_MAX = FzyJS.SCORE_MAX
private let SCORE_GAP_LEADING = FzyJS.SCORE_GAP_LEADING
private let SCORE_GAP_TRAILING = FzyJS.SCORE_GAP_TRAILING
private let SCORE_GAP_INNER = FzyJS.SCORE_GAP_INNER
private let SCORE_MATCH_CONSECUTIVE = FzyJS.SCORE_MATCH_CONSECUTIVE
private let SCORE_MATCH_SLASH = FzyJS.SCORE_MATCH_SLASH
private let SCORE_MATCH_CAPITAL = FzyJS.SCORE_MATCH_CAPITAL
private let SCORE_MATCH_DOT = FzyJS.SCORE_MATCH_DOT

// MARK: - FzyJSTests

struct FzyJSTests {
  @Test
  func `should prefer starts of words`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L519-L524
    #expect(
      FzyJS.score("amor", "app/models/order")
        > FzyJS.score("amor", "app/models/zrder")
    )
  }

  @Test
  func `should prefer consecutive letters`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L526-L532
    #expect(
      FzyJS.score("amo", "app/models/foo")
        > FzyJS.score("amo", "app/m/foo")
    )
  }

  @Test
  func `should prefer contiguous over letter following period`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L534-L539
    #expect(
      FzyJS.score("gemfil", "Gemfile.lock")
        < FzyJS.score("gemfil", "Gemfile")
    )
  }

  @Test
  func `should prefer shorter matches`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L541-L549
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
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L551-L555
    #expect(
      FzyJS.score("test", "tests")
        > FzyJS.score("test", "testing")
    )
  }

  @Test
  func `should prefer start of candidate`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L556-L562
    #expect(
      FzyJS.score("test", "testing")
        > FzyJS.score("test", "/testing")
    )
  }

  @Test
  func `score exact score`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L564-L572
    #expect(FzyJS.score("abc", "abc") == SCORE_MAX)
    #expect(FzyJS.score("aBc", "abC") == SCORE_MAX)
  }

  @Test
  func `score empty query`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L574-L583
    #expect(FzyJS.score("", "") == SCORE_MIN)
    #expect(FzyJS.score("", "a") == SCORE_MIN)
    #expect(FzyJS.score("", "bb") == SCORE_MIN)
  }

  @Test
  func `score gaps`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L585-L598
    #expect(abs(FzyJS.score("a", "*a") - SCORE_GAP_LEADING) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "*ba") - SCORE_GAP_LEADING * 2) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "**a*") - (SCORE_GAP_LEADING * 2 + SCORE_GAP_TRAILING)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "**a**") - (SCORE_GAP_LEADING * 2 + SCORE_GAP_TRAILING * 2)) < floatingPointTolerance)
    #expect(abs(FzyJS
        .score("aa", "**aa**") - (SCORE_GAP_LEADING * 2 + SCORE_MATCH_CONSECUTIVE + SCORE_GAP_TRAILING * 2)) <
      floatingPointTolerance)
    #expect(abs(FzyJS
        .score("aa", "**a*a**") -
        (SCORE_GAP_LEADING + SCORE_GAP_LEADING + SCORE_GAP_INNER + SCORE_GAP_TRAILING + SCORE_GAP_TRAILING)) <
      floatingPointTolerance)
  }

  @Test
  func `score consecutive`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L600-L608
    #expect(abs(FzyJS.score("aa", "*aa") - (SCORE_GAP_LEADING + SCORE_MATCH_CONSECUTIVE)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("aaa", "*aaa") - (SCORE_GAP_LEADING + SCORE_MATCH_CONSECUTIVE * 2)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("aaa", "*a*aa") - (SCORE_GAP_LEADING + SCORE_GAP_INNER + SCORE_MATCH_CONSECUTIVE)) <
      floatingPointTolerance)
  }

  @Test
  func `score slash`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L610-L617
    #expect(abs(FzyJS.score("a", "/a") - (SCORE_GAP_LEADING + SCORE_MATCH_SLASH)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "*/a") - (SCORE_GAP_LEADING * 2 + SCORE_MATCH_SLASH)) < floatingPointTolerance)
    #expect(abs(FzyJS
        .score("aa", "a/aa") - (SCORE_GAP_LEADING * 2 + SCORE_MATCH_SLASH + SCORE_MATCH_CONSECUTIVE)) < floatingPointTolerance)
  }

  @Test
  func `score capital`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L619-L626
    #expect(abs(FzyJS.score("a", "bA") - (SCORE_GAP_LEADING + SCORE_MATCH_CAPITAL)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "baA") - (SCORE_GAP_LEADING * 2 + SCORE_MATCH_CAPITAL)) < floatingPointTolerance)
    #expect(abs(FzyJS
        .score("aa", "baAa") - (SCORE_GAP_LEADING * 2 + SCORE_MATCH_CAPITAL + SCORE_MATCH_CONSECUTIVE)) <
      floatingPointTolerance)
  }

  @Test
  func `score dot`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L628-L636
    #expect(abs(FzyJS.score("a", ".a") - (SCORE_GAP_LEADING + SCORE_MATCH_DOT)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "*a.a") - (SCORE_GAP_LEADING * 3 + SCORE_MATCH_DOT)) < floatingPointTolerance)
    #expect(abs(FzyJS.score("a", "*a.a") - (SCORE_GAP_LEADING + SCORE_GAP_INNER + SCORE_MATCH_DOT)) < floatingPointTolerance)
  }

  @Test
  func `positions consecutive`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L640-L645
    let candidate = "app/models/foo"

    #expect(
      FzyJS.positions("amo", candidate)
        == [0, 4, 5].map { candidate.index(candidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions start of word`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L647-L661
    let candidate = "app/models/order"

    #expect(
      FzyJS.positions("amor", candidate)
        == [0, 4, 11, 12].map { candidate.index(candidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions no bonuses`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L663-L673
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
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L674-L680
    let candidate = "a/a/b/c/c"

    #expect(
      FzyJS.positions("abc", candidate)
        == [2, 4, 6].map { candidate.index(candidate.startIndex, offsetBy: $0) }
    )
  }

  @Test
  func `positions exact match`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/test.js#L682-L688
    let candidate = "foo"

    #expect(FzyJS.positions("foo", candidate) == Array(candidate.indices))
  }

  @Test
  func `rank composes the public fzy api into positions`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/index.js#L787-L939
    let candidate = "app/models/order"
    let rank = FzyJS.rank("amor", candidate)

    #expect(rank.rank == FzyJS.score("amor", candidate))
    #expect(rank.hasMatch == FzyJS.hasMatch("amor", candidate))
    #expect(rank.positions == FzyJS.positions("amor", candidate))
  }

  @Test
  func `rank guards the equal length primitive edge case`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/index.js#L796-L806
    let rank = FzyJS.rank("abc", "xyz")

    #expect(FzyJS.score("abc", "xyz") == SCORE_MAX)
    #expect(!rank.hasMatch)
    #expect(rank.rank == SCORE_MIN)
    #expect(rank.positions.isEmpty)
  }

  @Test
  func `hasMatch follows subsequence semantics`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/index.js#L923-L939
    #expect(FzyJS.hasMatch("amo", "app/models/foo"))
    #expect(!FzyJS.hasMatch("obtv", "oaktextview.mm"))
  }

  @Test
  func `no subsequence match should return negative infinity`() {
    // https://github.com/jhawthorn/fzy.js/blob/main/index.js#L787-L831
    #expect(FzyJS.score("obtv", "oaktextview.mm") == SCORE_MIN)
    #expect(!FzyJS.hasMatch("obtv", "oaktextview.mm"))
  }
}
