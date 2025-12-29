import Foundation

// port of https://github.com/textmate/textmate/blob/master/Frameworks/text/src/ranker.cc at commit hash c93030b
// lhs: filter, rhs: candidate
func calculateRank(lhs: String, rhs: String) -> Score {
  let n = lhs.count
  let m = rhs.count

  var matrix = [[Int]](
    repeating: [Int](repeating: 0, count: m),
    count: n
  )

  var first = [Int](repeating: m, count: n)
  var last = [Int](repeating: 0, count: n)
  var capitals = [Bool](repeating: false, count: m)

  var out = [Range<Int>]()

  var atBow = true
  for (j, ch) in rhs.enumerated() {
    let isAlnum = ch.isASCII && (ch.isLetter || ch.isWholeNumber)
    capitals[j] = (atBow && isAlnum) || ch.isUppercase
    atBow = !isAlnum && ch != "'" && ch != "."
  }

  for (i, lhsChar) in lhs.enumerated() {
    let offset = i == 0 ? 0 : (first[i - 1] + 1)
    let rhsStartIndex = rhs.index(rhs.startIndex, offsetBy: offset)
    for (j, rhsChar) in rhs[rhsStartIndex ..< rhs.endIndex].enumerated() where lhsChar.lowercased() == rhsChar.lowercased() {
      let j = j + offset
      matrix[i][j] = (i == 0 || j == 0) ? 1 : matrix[i - 1][j - 1] + 1
      first[i] = min(j, first[i])
      last[i] = max(j + 1, last[i])
    }
  }

  for i in stride(from: n - 1, to: 0, by: -1) {
    var bound = last[i] - 1
    if bound < last[i - 1] {
      while first[i - 1] < bound, matrix[i - 1][bound - 1] == 0 {
        bound -= 1
      }
      last[i - 1] = bound
    }
  }

  for i in stride(from: n - 1, to: 0, by: -1) {
    for j in first[i] ..< last[i] where matrix[i][j] != 0 && matrix[i - 1][j - 1] != 0 {
      matrix[i - 1][j - 1] = matrix[i][j]
    }
  }

  for i in 0 ..< n {
    for j in first[i] ..< last[i] where matrix[i][j] > 1 && i + 1 < n && j + 1 < m {
      matrix[i + 1][j + 1] = matrix[i][j] - 1
    }
  }

  // MARK: - greedy walk of matrix

  var capitalsTouched = 0
  var substrings = 0
  var prefixSize = 0

  var i = 0
  while i < n {
    var bestJIndex = 0
    var bestJLength = 0

    for j in first[i] ..< last[i] {
      if matrix[i][j] != 0, capitals[j] {
        bestJIndex = j
        bestJLength = matrix[i][j]
        for k in j ..< j + bestJLength {
          capitalsTouched += capitals[k] ? 1 : 0
        }
        break

      } else if bestJLength < matrix[i][j] {
        bestJIndex = j
        bestJLength = matrix[i][j]
      }
    }

    if i == 0 {
      prefixSize = bestJIndex
    }

    var len = 0
    var foundCapital = false

    repeat {
      i += 1
      len += 1
      if i == n { break }

      first[i] = max(bestJIndex + len, first[i])
      if len < bestJLength, n < 4 {
        if capitals[first[i]] {
          continue
        }

        for j in first[i] ..< last[i] where !foundCapital && matrix[i][j] != 0 && capitals[j] {
          foundCapital = true
        }
      }
    } while len < bestJLength && !foundCapital

    out.append(bestJIndex..<bestJIndex + len)

    substrings += 1
  }

  // MARK: - Calculate rank based on walk

  let totalCapitals = capitals[0 ..< m].filter { $0 }.count
  var score = 0.0
  let denom = Double(n) * (Double(n) + 1.0) + 1.0

  if n == capitalsTouched {
    score = (denom - 1) / denom
  } else {
    let substract = Double(substrings) * Double(n) + (Double(n) - Double(capitalsTouched))
    score = (denom - substract) / denom
  }
  score += Double(m - prefixSize) / Double(m) / (2 * denom)
  score += Double(capitalsTouched) / Double(totalCapitals) / (4 * denom)
  score += Double(n) / Double(m) / (8 * denom)

  return Score(rank: score, ranges: out)
}
