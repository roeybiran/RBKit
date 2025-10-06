import Carbon
import Testing
@testable import AXKit

@Suite
struct `AXMenuItemModifiers+CustomStringConvertible Tests` {

  @Test
  func `description, with command only, should be ⌘`() {
    let mods = "\(AXMenuItemModifiers([]))"
    #expect(mods == "⌘")
  }

  @Test
  func `description, with option, should be ⌥⌘`() {
    let mods = "\(AXMenuItemModifiers([.option]))"
    #expect(mods == "⌥⌘")
  }

  @Test
  func `description, with control, should be ⌃⌘`() {
    let mods = "\(AXMenuItemModifiers([.control]))"
    #expect(mods == "⌃⌘")
  }

  @Test
  func `description, with shift, should be ⇧⌘`() {
    let mods = "\(AXMenuItemModifiers([.shift]))"
    #expect(mods == "⇧⌘")
  }

  @Test
  func `description, with control + option + shift + noCommand, should be ⌃⌥⇧`() {
    let mods = "\(AXMenuItemModifiers([.shift, .control, .option, .noCommand].shuffled()))"
    #expect(mods == "⌃⌥⇧")
  }

  @Test
  func `description, with control + option + noCommand, should be ⌃⌥`() {
    let mods = "\(AXMenuItemModifiers([.control, .option, .noCommand].shuffled()))"
    #expect(mods == "⌃⌥")
  }

  @Test
  func `description, with control + shift + noCommand, should be ⌃⇧`() {
    let mods = "\(AXMenuItemModifiers([.control, .shift, .noCommand].shuffled()))"
    #expect(mods == "⌃⇧")
  }

  @Test
  func `description, with option + shift + noCommand, should be ⌥⇧`() {
    let mods = "\(AXMenuItemModifiers([.option, .shift, .noCommand].shuffled()))"
    #expect(mods == "⌥⇧")
  }

  @Test
  func `description, with control + option + shift + command, should be ⌃⌥⇧⌘`() {
    let mods = "\(AXMenuItemModifiers([.shift, .control, .option].shuffled()))"
    #expect(mods == "⌃⌥⇧⌘")
  }

  @Test
  func `description, with single modifier + noCommand, should show single modifier without command`() {
    for item in [(AXMenuItemModifiers.control, "⌃"), (.shift, "⇧"), (.option, "⌥")] {
      #expect("\(item.0.union(.noCommand))" == item.1)
    }
  }

  @Test
  func `description, with noCommand only, should be empty`() {
    let mods = "\(AXMenuItemModifiers([.noCommand]))"
    #expect(mods == "")
  }

  @Test
  func `description, with raw value 0x18, should be 🌐`() {
    let mods = "\(AXMenuItemModifiers(rawValue: 0x18))"
    #expect(mods == "🌐")
  }
}
