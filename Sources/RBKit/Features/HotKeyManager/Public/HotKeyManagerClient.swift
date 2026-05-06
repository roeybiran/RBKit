import Carbon
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - HotKeyManagerClient

@DependencyClient
public struct HotKeyManagerClient: Sendable {
  public var start: @MainActor @Sendable () -> Void
  public var stop: @MainActor @Sendable () -> Void
  public var registerDefaults: @MainActor @Sendable (_ defaults: [HotKey.ID: HotKey]) -> Void
  public var register: @MainActor @Sendable (_ hotKey: HotKey, _ id: HotKey.ID) -> Void
  public var unregister: @MainActor @Sendable (_ id: HotKey.ID) -> Void
  public var presses: @MainActor @Sendable (_ id: HotKey.ID) -> AsyncStream<EventType> = { _ in .finished }
  public var status: @MainActor @Sendable (_ id: HotKey.ID) -> HotKeyStatus?
}

extension HotKeyManagerClient {
  public static func migrateLegacyDefaults(_ mapping: [String: HotKey.ID]) {
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    guard var container = userDefaultsClient.dictionary(forKey: .DEFAULTS_ALL_HOT_KEYS_KEY) else { return }

    var didChange = false
    for (legacyName, id) in mapping {
      guard let legacyValue = container[legacyName] else { continue }

      let idKey = String(id)
      if container[idKey] == nil {
        container[idKey] = legacyValue
      }
      container.removeValue(forKey: legacyName)
      didChange = true
    }

    if didChange {
      userDefaultsClient.setAny(container, .DEFAULTS_ALL_HOT_KEYS_KEY)
    }
  }
}

// MARK: DependencyKey

extension HotKeyManagerClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    start: { manager.start() },
    stop: { manager.stop() },
    registerDefaults: { defaults in
      manager.registerDefaults(defaults)
    },
    register: { hotKey, id in
      manager.register(hotKey: hotKey, id: id)
    },
    unregister: { id in
      manager.unregister(id: id)
    },
    presses: { id in
      manager.presses(of: id)
    },
    status: { id in
      manager.status(of: id)
    },
  )

  public static let testValue = Self()

  // MARK: Private

  @MainActor private static let manager = HotKeyManager()
}

extension DependencyValues {
  public var hotKeyManagerClient: HotKeyManagerClient {
    get { self[HotKeyManagerClient.self] }
    set { self[HotKeyManagerClient.self] = newValue }
  }
}
