import Foundation

public struct FrecencyCollection<T: FrecencyID> {
  public private(set) var items = [T: FrecencyItem<T>]()
  var queries = [String: [FrecencyItem<T>]]()

  public func score(for item: T, referencing date: Date = .now, in calendar: Calendar = .current)
    -> Double
  {
    items[item]?.score(referencing: date, in: calendar) ?? 0
  }

  public mutating func add(entry: T, query: String? = nil, timestamp: Date = .now) {
    items = items.merging([entry: FrecencyItem(id: entry, visits: [timestamp], count: 1)]) {
      current, new in
      FrecencyItem(
        id: new.id, visits: (current.visits + new.visits).suffix(.frecencySamplingLimit),
        count: current.count + new.count)
    }
    // if let query {
    //   queries[query, default: []].append(item)
    // }
  }

  public init() {}
}

extension FrecencyCollection {
  public init(items: [T: FrecencyItem<T>] = [:]) {
    self.items = items
  }

  public init(items: [FrecencyItem<T>] = []) {
    items.forEach { self.items[$0.id] = $0 }
  }
}

extension FrecencyCollection: Hashable {}

extension FrecencyCollection: Codable {}

extension FrecencyCollection: Sendable {}
