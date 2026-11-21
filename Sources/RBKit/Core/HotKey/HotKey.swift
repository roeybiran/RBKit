// MARK: - HotKey

public struct HotKey: Hashable, Sendable {
  public init(key: Key, modifiers: Modifiers) {
    self.key = key
    self.modifiers = modifiers
  }

  public typealias ID = Int

  // MARK: Public

  public let key: Key
  public let modifiers: Modifiers
}
