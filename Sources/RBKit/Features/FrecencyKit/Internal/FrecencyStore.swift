import Dependencies
import Foundation
import Sharing

// MARK: - FrecencyStore

struct FrecencyStore<Key: FrecencyID>: Sendable {

  mutating func add(_ value: Key, timestamp: Date = .now) {
    $collection.withLock {
      $0.add(entry: value, timestamp: timestamp)
    }
  }

  func score(for item: Key) -> Double {
    collection.score(for: item)
  }

  // MARK: Internal

  @Shared(.fileStorage(.frecencyURL)) private var collection = FrecencyCollection<Key>()

}
