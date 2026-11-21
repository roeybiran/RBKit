import Carbon
import Testing
@testable import RBKit

// MARK: - SymbolicHotKeysClientTests

struct SymbolicHotKeysClientTests {
  @Test
  func `isConflicting should return true for an enabled matching hot key`() {
    var sut = SymbolicHotKeysClient.testValue
    sut.copySymbolicHotKeys = {
      (
        CFArray.mock(dicts: (key: Key.a.keyCode, mods: Modifiers(cocoa: [.command]).carbon, enabled: true)),
        noErr,
      )
    }

    #expect(sut.isConflicting(key: .a, modifiers: [.command]))
  }

  @Test
  func `isConflicting should return false for a disabled matching hot key`() {
    var sut = SymbolicHotKeysClient.testValue
    sut.copySymbolicHotKeys = {
      (
        CFArray.mock(dicts: (key: Key.a.keyCode, mods: Modifiers(cocoa: [.command]).carbon, enabled: false)),
        noErr,
      )
    }

    #expect(!sut.isConflicting(key: .a, modifiers: [.command]))
  }

  @Test
  func `isConflicting should ignore unknown system key codes`() {
    var sut = SymbolicHotKeysClient.testValue
    sut.copySymbolicHotKeys = {
      (
        CFArray.mock(dicts: (key: Int(kVK_Command), mods: Modifiers(cocoa: [.command]).carbon, enabled: true)),
        noErr,
      )
    }

    #expect(!sut.isConflicting(key: .a, modifiers: [.command]))
  }
}

extension CFArray {
  static func mock(dicts: (key: Int, mods: Int, enabled: Bool)...) -> Unmanaged<CFArray> {
    let nsArray = NSArray(array: dicts.map {
      NSDictionary(dictionary: [
        kHISymbolicHotKeyEnabled: $0.enabled,
        kHISymbolicHotKeyCode: $0.key,
        kHISymbolicHotKeyModifiers: $0.mods,
      ])
    })
    return Unmanaged.passRetained(nsArray as CFArray)
  }
}
