import Carbon
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - UnicodeUtilitiesClient

/// See also:
/// - [github.com/sindresorhus/KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
/// - [github.com/davedelong/DDHotKey](https://github.com/davedelong/DDHotKey/blob/e0481f648e0bc7e55d183622b00510b6721152d8/DDHotKeyUtilities.m#L118)
/// - [github.com/cocoabits/MASShortcut](https://github.com/cocoabits/MASShortcut/blob/6f2603c6b6cc18f64a799e5d2c9d3bbc467c413a/Framework/Model/MASShortcut.m#L164)
@DependencyClient
public struct UnicodeUtilitiesClient: Sendable {
  public var translate: @Sendable (_ keyCode: Int) -> String?
}

// MARK: DependencyKey

extension UnicodeUtilitiesClient: DependencyKey {
  public static let liveValue = Self(
    translate: { keyCode in
      guard
        let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
        let layoutDataPointer = TISGetInputSourceProperty(
          source,
          kTISPropertyUnicodeKeyLayoutData,
        )
      else {
        return nil
      }

      let layoutData = unsafeBitCast(layoutDataPointer, to: CFData.self)
      let keyLayout = unsafeBitCast(
        CFDataGetBytePtr(layoutData),
        to: UnsafePointer<UCKeyboardLayout>.self,
      )
      var deadKeyState: UInt32 = 0
      let maxLength = 4
      var length = 0
      var characters = [UniChar](repeating: 0, count: maxLength)

      let result = UCKeyTranslate(
        keyLayout,
        UInt16(keyCode),
        UInt16(kUCKeyActionDisplay),
        0,
        UInt32(LMGetKbdType()),
        OptionBits(kUCKeyTranslateNoDeadKeysBit),
        &deadKeyState,
        maxLength,
        &length,
        &characters,
      )

      guard result == noErr else {
        return nil
      }

      return String(utf16CodeUnits: characters, count: length)
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var unicodeUtilitiesClient: UnicodeUtilitiesClient {
    get { self[UnicodeUtilitiesClient.self] }
    set { self[UnicodeUtilitiesClient.self] = newValue }
  }
}
