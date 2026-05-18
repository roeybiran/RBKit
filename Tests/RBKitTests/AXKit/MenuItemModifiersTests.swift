import ApplicationServices
import Carbon
import Testing
@testable import AXKit

@Suite
struct `MenuItemModifiers+CustomStringConvertible Tests` {

  @Test
  func `description, with command only, should be ⌘`() {
    let mods = "\(MenuItemModifiers([]))"
    #expect(mods == "⌘")
  }

  @Test
  func `description, with option, should be ⌥⌘`() {
    let mods = "\(MenuItemModifiers([.option]))"
    #expect(mods == "⌥⌘")
  }

  @Test
  func `description, with control, should be ⌃⌘`() {
    let mods = "\(MenuItemModifiers([.control]))"
    #expect(mods == "⌃⌘")
  }

  @Test
  func `description, with shift, should be ⇧⌘`() {
    let mods = "\(MenuItemModifiers([.shift]))"
    #expect(mods == "⇧⌘")
  }

  @Test
  func `description, with control + option + shift + noCommand, should be ⌃⌥⇧`() {
    let mods = "\(MenuItemModifiers([.shift, .control, .option, .noCommand].shuffled()))"
    #expect(mods == "⌃⌥⇧")
  }

  @Test
  func `description, with control + option + noCommand, should be ⌃⌥`() {
    let mods = "\(MenuItemModifiers([.control, .option, .noCommand].shuffled()))"
    #expect(mods == "⌃⌥")
  }

  @Test
  func `description, with control + shift + noCommand, should be ⌃⇧`() {
    let mods = "\(MenuItemModifiers([.control, .shift, .noCommand].shuffled()))"
    #expect(mods == "⌃⇧")
  }

  @Test
  func `description, with option + shift + noCommand, should be ⌥⇧`() {
    let mods = "\(MenuItemModifiers([.option, .shift, .noCommand].shuffled()))"
    #expect(mods == "⌥⇧")
  }

  @Test
  func `description, with control + option + shift + command, should be ⌃⌥⇧⌘`() {
    let mods = "\(MenuItemModifiers([.shift, .control, .option].shuffled()))"
    #expect(mods == "⌃⌥⇧⌘")
  }

  @Test
  func `description, with single modifier + noCommand, should show single modifier without command`() {
    for item in [(MenuItemModifiers.control, "⌃"), (.shift, "⇧"), (.option, "⌥")] {
      #expect("\(item.0.union(.noCommand))" == item.1)
    }
  }

  @Test
  func `description, with noCommand only, should be empty`() {
    let mods = "\(MenuItemModifiers([.noCommand]))"
    #expect(mods == "")
  }

  @Test
  func `raw values should match accessibility menu item modifier masks`() {
    #expect(MenuItemModifiers.shift.rawValue == AXMenuItemModifiers.shift.rawValue)
    #expect(MenuItemModifiers.option.rawValue == AXMenuItemModifiers.option.rawValue)
    #expect(MenuItemModifiers.control.rawValue == AXMenuItemModifiers.control.rawValue)
    #expect(MenuItemModifiers.noCommand.rawValue == AXMenuItemModifiers.noCommand.rawValue)
  }

  @Test
  func `description, with raw value 0x18, should be 🌐`() {
    let mods = "\(MenuItemModifiers(rawValue: 0x18))"
    #expect(mods == "🌐")
  }
}
