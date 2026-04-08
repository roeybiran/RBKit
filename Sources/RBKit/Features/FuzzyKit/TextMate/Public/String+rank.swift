import Foundation

extension String {
  public func rank(for filter: String) -> Score {
    if filter.isEmpty {
      return Score(rank: 1, ranges: [])
    } else if !filter.lowercased().isSubset(of: lowercased()) {
      return Score(rank: 0, ranges: [])
    } else if filter == self {
      return Score(rank: 1, ranges: [0 ..< filter.count])
    } else {
      let bytes = Double(utf8.count)
      let filterBytes = Double(filter.utf8.count)
      return filterBytes * bytes > 8096
        ? Score(rank: filterBytes / bytes, ranges: [])
        : calculateRank(lhs: filter, rhs: self)
    }
  }

}
