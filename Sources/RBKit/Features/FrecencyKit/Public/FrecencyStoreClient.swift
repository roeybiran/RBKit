import Dependencies
import DependenciesMacros
import Foundation
import os

// MARK: - FrecencyStoreClient

@DependencyClient
public struct FrecencyStoreClient<Key: FrecencyID>: Sendable {
  public var add: @Sendable (_ item: Key) -> Void
  public var score: @Sendable (_ forItem: Key) -> Double = { _ in 0 }
}

// MARK: DependencyKey

extension FrecencyStoreClient: DependencyKey {
  public static var liveValue: Self {
    let store = LockedFrecencyStore<Key>()
    return .init(
      add: { store.add($0) },
      score: { store.score(for: $0) },
    )
  }

  public static var testValue: Self {
    .init()
  }
}

// MARK: - LockedFrecencyStore

private final class LockedFrecencyStore<Key: FrecencyID>: Sendable {

  // MARK: Internal

  func add(_ item: Key) {
    store.withLock {
      $0.add(item)
    }
  }

  func score(for item: Key) -> Double {
    store.withLock {
      $0.score(for: item)
    }
  }

  // MARK: Private

  private let store = OSAllocatedUnfairLock(initialState: FrecencyStore<Key>())

}
