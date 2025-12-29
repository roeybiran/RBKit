import Dependencies
import DependenciesMacros
import Foundation

// MARK: - FrecencyStoreClient

@DependencyClient
public struct FrecencyStoreClient<Key: FrecencyID>: Sendable {
  public var load: @Sendable () -> Void
  public var save: @Sendable () -> Void
  public var add: @Sendable (_ item: Key) -> Void
  public var score: @Sendable (_ forItem: Key) -> Double = { _ in 0 }
  public var items: @Sendable () -> [Key: FrecencyItem<Key>] = { [:] }
}

// MARK: DependencyKey

extension FrecencyStoreClient: DependencyKey {
  public static var liveValue: Self {
    var store = FrecencyStore<Key>(url: FrecencyStore<Key>.defaultURL())
    return .init(
      load: { try? store.load() },
      save: { try? store.save() },
      add: { store.add($0) },
      score: { store.score(for: $0) },
      items: { store.items.items }
    )
  }

  public static var testValue: Self { .init() }
}
