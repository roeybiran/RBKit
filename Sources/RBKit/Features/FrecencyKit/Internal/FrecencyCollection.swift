import Foundation

// MARK: - FrecencyCollection

struct FrecencyCollection<T: FrecencyID>: Hashable, Codable, Sendable {

  // MARK: Internal

  private(set) var items = [T: FrecencyRecord]()

  func score(for item: T) -> Double {
    items[item]?.score() ?? 0
  }

  mutating func add(entry: T, timestamp: Date = .now) {
    items = items.merging([entry: FrecencyRecord(visits: [timestamp], count: 1)]) {
      current, new in
      FrecencyRecord(
        visits: Array((current.visits + new.visits).suffix(.frecencySamplingLimit)),
        count: current.count + new.count,
      )
    }
  }

}
