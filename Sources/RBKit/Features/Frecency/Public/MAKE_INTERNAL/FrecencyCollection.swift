import Foundation

// MARK: - FrecencyCollection

public struct FrecencyCollection<T: FrecencyID> {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public private(set) var items = [T: FrecencyItem<T>]()

  public func score(for item: T, referencing date: Date = .now, in calendar: Calendar = .current)
    -> Double
  {
    items[item]?.score(referencing: date, in: calendar) ?? 0
  }

  public mutating func add(entry: T, query _: String? = nil, timestamp: Date = .now) {
    items = items.merging([entry: FrecencyItem(id: entry, visits: [timestamp], count: 1)]) {
      current, new in
      FrecencyItem(
        id: new.id, visits: (current.visits + new.visits).suffix(.frecencySamplingLimit),
        count: current.count + new.count
      )
    }
    // if let query {
    //   queries[query, default: []].append(item)
    // }
  }

  // MARK: Internal

  var queries = [String: [FrecencyItem<T>]]()

}

extension FrecencyCollection {
  public init(items: [T: FrecencyItem<T>] = [:]) {
    self.items = items
  }

  public init(items: [FrecencyItem<T>] = []) {
    for item in items { self.items[item.id] = item }
  }
}

extension FrecencyCollection: Hashable { }

extension FrecencyCollection: Codable { }

extension FrecencyCollection: Sendable { }
