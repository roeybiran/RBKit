import Foundation

// MARK: - FrecencyCollection

struct FrecencyCollection<T: FrecencyID>: Hashable, Codable, Sendable {

  // MARK: Internal

  private(set) var items = [T: FrecencyRecord]()

  func score(for item: T) -> Double {
    items[item]?.score() ?? 0
  }

  mutating func add(entry: T, timestamp: Date = .now) {
    if var record = items[entry] {
      record.visits = (record.visits + [timestamp]).suffix(.FRECENCY_SAMPLING_LIMIT)
      record.count += 1
      items[entry] = record
    } else {
      items[entry] = FrecencyRecord(visits: [timestamp], count: 1)
    }
  }

}
