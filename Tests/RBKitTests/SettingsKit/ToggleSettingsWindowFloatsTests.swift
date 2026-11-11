import AppKit
import Dependencies
import Testing
@testable import RBKit

@MainActor
struct ToggleSettingsWindowFloatsTests {

  @Test(arguments: [false, true])
  func toggle(flag: Bool) async {
    await confirmation(expectedCount: 2) { c in
      withDependencies { d in
        d.userDefaultsClient.bool = { key in
          #expect(key == .DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING)
          #expect(key == "RBSettingsKit_isWindowFloating")
          c()
          return flag
        }
        d.userDefaultsClient.setBool = { value, key in
          #expect(value != flag)
          #expect(key == .DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING)
          #expect(key == "RBSettingsKit_isWindowFloating")
          c()
        }
      } operation: {
        let sender = NSMenuItem.ToggleSettingsWindowFloats()
        sender.toggleSettingsWindowFloats(sender)
      }
    }
  }

  @Test(arguments: [(false, NSControl.StateValue.off), (true, .on)])
  func validate(pair: (Bool, NSControl.StateValue)) async {
    await confirmation { c in
      withDependencies { d in
        d.userDefaultsClient.bool = { key in
          c()
          #expect(key == .DEFAULTS_KEY_IS_SETTINGS_WINDOW_FLOATING)
          #expect(key == "RBSettingsKit_isWindowFloating")
          return pair.0
        }
      } operation: {
        let sender = NSMenuItem.ToggleSettingsWindowFloats()
        #expect(sender.validateMenuItem(sender))
        #expect(sender.state == pair.1)
      }
    }
  }
}
