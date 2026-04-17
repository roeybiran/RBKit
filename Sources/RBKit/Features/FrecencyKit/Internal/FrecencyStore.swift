import Dependencies
import Foundation
import Sharing

// MARK: - FrecencyStore

struct FrecencyStore<Key: FrecencyID>: Sendable {

  // MARK: Internal

  mutating func add(_ value: Key, timestamp: Date = .now) {
    $collection.withLock {
      $0.add(entry: value, timestamp: timestamp)
    }
  }

  func score(for item: Key) -> Double {
    #if DEBUG
    if UserDefaults.standard.bool(forKey: "_ignoreRecents") {
      return 0
    }
    #endif

    return collection.score(for: item)
  }

  // MARK: Private

  @Shared(.fileStorage(.frecencyURL)) private var collection = FrecencyCollection<Key>()

}
