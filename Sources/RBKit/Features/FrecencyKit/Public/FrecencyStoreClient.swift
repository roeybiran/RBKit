import Dependencies
import DependenciesMacros
import Foundation

// MARK: - FrecencyStoreClient

@DependencyClient
public struct FrecencyStoreClient<Key: FrecencyID>: Sendable {
  public var add: @Sendable (_ item: Key) -> Void
  public var score: @Sendable (_ forItem: Key) -> Double = { _ in 0 }
}

// MARK: DependencyKey

extension FrecencyStoreClient: DependencyKey {
  public static var liveValue: Self {
    var store = FrecencyStore<Key>()
    return .init(
      add: { store.add($0) },
      score: { store.score(for: $0) },
    )
  }

  public static var testValue: Self {
    .init()
  }
}
