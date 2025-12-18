extension String {
  func isSubset(of haystack: String) -> Bool {
    var m = 0
    var n = 0

    for needleChar in self {
      var didMatch = false
      let haystackStartIndex = haystack.index(haystack.startIndex, offsetBy: m)
      for (i, haystackChar) in haystack[haystackStartIndex ..< haystack.endIndex].enumerated() {
        if needleChar == haystackChar {
          didMatch = true
          m += i + 1
          n += 1
          break
        }
      }
      if !didMatch { return false }
    }
    return n == count
  }
}

