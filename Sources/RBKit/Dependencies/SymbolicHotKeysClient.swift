import Carbon
import Dependencies
import DependenciesMacros
import Foundation
import os

private let symbolicHotKeysClientLogger = Logger(
  subsystem: "com.roeybiran.RBKit",
  category: "SymbolicHotKeysClient",
)

// MARK: - SymbolicHotKeysClient

@DependencyClient
public struct SymbolicHotKeysClient: Sendable {
  public var copySymbolicHotKeys: @Sendable () -> (Unmanaged<CFArray>?, OSStatus) = { (nil, 0) }
}

extension SymbolicHotKeysClient {
  public func isConflicting(key: Key, modifiers: Modifiers) -> Bool {
    let (hotKeysUnmanaged, status) = copySymbolicHotKeys()
    if status != noErr {
      symbolicHotKeysClientLogger.error("Error getting system hot keys")
      return false
    }

    let systemHotKeys = (hotKeysUnmanaged?.takeRetainedValue() as? [[String: Any]]) ?? []
    return systemHotKeys.contains { systemHotKey in
      guard
        (systemHotKey[kHISymbolicHotKeyEnabled] as? Bool) == true,
        let carbonKeyCode = systemHotKey[kHISymbolicHotKeyCode] as? Int,
        let systemKey = Key(rawValue: carbonKeyCode),
        let carbonModifiers = systemHotKey[kHISymbolicHotKeyModifiers] as? Int
      else {
        return false
      }

      let systemModifiers = Modifiers(carbon: carbonModifiers)
      return key == systemKey && modifiers == systemModifiers
    }
  }
}

// MARK: DependencyKey

extension SymbolicHotKeysClient: DependencyKey {
  public static let liveValue = Self(
    copySymbolicHotKeys: {
      var hotKeysUnmanaged: Unmanaged<CFArray>?
      let status = CopySymbolicHotKeys(&hotKeysUnmanaged)
      return (hotKeysUnmanaged, status)
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var symbolicHotKeysClient: SymbolicHotKeysClient {
    get { self[SymbolicHotKeysClient.self] }
    set { self[SymbolicHotKeysClient.self] = newValue }
  }
}
