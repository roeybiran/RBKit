import Foundation

// https://github.com/jhawthorn/fzy.js

public enum FuzzyMatcherV2Core {

  // MARK: Public

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L1
  public static let SCORE_MIN = -Double.infinity

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L2
  public static let SCORE_MAX = Double.infinity

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L4
  public static let SCORE_GAP_LEADING = -0.005

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L5
  public static let SCORE_GAP_TRAILING = -0.005

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L6
  public static let SCORE_GAP_INNER = -0.01

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L7
  public static let SCORE_MATCH_CONSECUTIVE = 1.0

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L8
  public static let SCORE_MATCH_SLASH = 0.9

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L9
  public static let SCORE_MATCH_WORD = 0.8

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L10
  public static let SCORE_MATCH_CAPITAL = 0.7

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L11
  public static let SCORE_MATCH_DOT = 0.6

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L91-L121
  public static func score(_ needle: String, _ haystack: String) -> Double {
    let n = needle.count
    let m = haystack.count

    if n == 0 || m == 0 {
      return SCORE_MIN
    }

    if n == m {
      return SCORE_MAX
    }

    if m > 1024 {
      return SCORE_MIN
    }

    var D = [[Double]](
      repeating: [Double](repeating: SCORE_MIN, count: m),
      count: n
    )
    var M = [[Double]](
      repeating: [Double](repeating: SCORE_MIN, count: m),
      count: n
    )

    compute(needle, haystack, &D, &M)

    return M[n - 1][m - 1]
  }

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L123-L176
  public static func positions(_ needle: String, _ haystack: String) -> [Int] {
    let n = needle.count
    let m = haystack.count

    if n == 0 || m == 0 {
      return []
    }

    if n == m {
      return Array(0 ..< n)
    }

    if m > 1024 {
      return []
    }

    var D = [[Double]](
      repeating: [Double](repeating: SCORE_MIN, count: m),
      count: n
    )
    var M = [[Double]](
      repeating: [Double](repeating: SCORE_MIN, count: m),
      count: n
    )

    compute(needle, haystack, &D, &M)

    var positions = [Int](repeating: 0, count: n)
    var match_required = false
    var haystackIndex = m - 1

    for needleIndex in stride(from: n - 1, through: 0, by: -1) {
      while haystackIndex >= 0 {
        if
          D[needleIndex][haystackIndex] != SCORE_MIN,

          match_required
          || D[needleIndex][haystackIndex] == M[needleIndex][haystackIndex]

        {
          match_required = needleIndex > 0
            && haystackIndex > 0
            && M[needleIndex][haystackIndex] == D[needleIndex - 1][haystackIndex - 1] + SCORE_MATCH_CONSECUTIVE
          positions[needleIndex] = haystackIndex
          haystackIndex -= 1
          break
        }

        haystackIndex -= 1
      }
    }

    return positions
  }

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L178-L187
  public static func hasMatch(_ needle: String, _ haystack: String) -> Bool {
    let needle = Array(needle.lowercased())
    let haystack = Array(haystack.lowercased())

    if needle.isEmpty {
      return true
    }

    var haystackIndex = 0

    for character in needle {
      while haystackIndex < haystack.count, haystack[haystackIndex] != character {
        haystackIndex += 1
      }

      if haystackIndex == haystack.count {
        return false
      }

      haystackIndex += 1
    }

    return true
  }

  // MARK: Internal

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L48-L89
  static func compute(
    _ needle: String,
    _ haystack: String,
    _ D: inout [[Double]],
    _ M: inout [[Double]],
  ) {
    let n = needle.count
    let m = haystack.count

    let lower_needle = Array(needle.lowercased())
    let lower_haystack = Array(haystack.lowercased())
    let match_bonus = precompute_bonus(haystack)

    for i in 0 ..< n {
      var prev_score = SCORE_MIN
      let gap_score = i == n - 1 ? SCORE_GAP_TRAILING : SCORE_GAP_INNER

      for j in 0 ..< m {
        if lower_needle[i] == lower_haystack[j] {
          var score = SCORE_MIN

          if i == 0 {
            score = Double(j) * SCORE_GAP_LEADING + match_bonus[j]
          } else if j > 0 {
            score = max(
              M[i - 1][j - 1] + match_bonus[j],
              D[i - 1][j - 1] + SCORE_MATCH_CONSECUTIVE,
            )
          }

          D[i][j] = score
          prev_score = max(score, prev_score + gap_score)
          M[i][j] = prev_score
        } else {
          D[i][j] = SCORE_MIN
          prev_score += gap_score
          M[i][j] = prev_score
        }
      }
    }
  }

  // MARK: Private

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L13-L15
  private static func islower(_ string: Character) -> Bool {
    string.lowercased() == String(string)
  }

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L17-L19
  private static func isupper(_ string: Character) -> Bool {
    string.uppercased() == String(string)
  }

  /// https://github.com/jhawthorn/fzy.js/blob/main/index.js#L21-L46
  private static func precompute_bonus(_ haystack: String) -> [Double] {
    let haystack = Array(haystack)
    var match_bonus = [Double]()
    match_bonus.reserveCapacity(haystack.count)

    var last_ch: Character = "/"
    for ch in haystack {
      if last_ch == "/" {
        match_bonus.append(SCORE_MATCH_SLASH)
      } else if last_ch == "-" || last_ch == "_" || last_ch == " " {
        match_bonus.append(SCORE_MATCH_WORD)
      } else if last_ch == "." {
        match_bonus.append(SCORE_MATCH_DOT)
      } else if islower(last_ch), isupper(ch) {
        match_bonus.append(SCORE_MATCH_CAPITAL)
      } else {
        match_bonus.append(0)
      }

      last_ch = ch
    }

    return match_bonus
  }

}
