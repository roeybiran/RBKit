import Carbon
import Testing
@testable import AXKit

struct `AXMenuItemModifiers+CustomStringConvertible Tests` {
  // MARK: - AXMenuItemModifiers+CustomStringConvertibleTests

  @Test
  func description_withCommand_shouldBeCmd() {
    let mods = "\(AXMenuItemModifiers([]))"
    #expect(mods == "⌘")
  }

  @Test
  func description_withOpt_shouldBeOptCmd() {
    let mods = "\(AXMenuItemModifiers([.option]))"
    #expect(mods == "⌥⌘")
  }

  @Test
  func description_withCtrl_shouldBeCtrlCmd() {
    let mods = "\(AXMenuItemModifiers([.control]))"
    #expect(mods == "⌃⌘")
  }

  @Test
  func description_withShift_shouldBeShift() {
    let mods = "\(AXMenuItemModifiers([.shift]))"
    #expect(mods == "⇧⌘")
  }

  @Test
  func description_withCtrlOptShift_shouldBeCtrlOptShift() {
    let mods = "\(AXMenuItemModifiers([.shift, .control, .option, .noCommand].shuffled()))"
    #expect(mods == "⌃⌥⇧")
  }

  @Test
  func description_withCtrlOpt_shouldBeCtrlOpt() {
    let mods = "\(AXMenuItemModifiers([.control, .option, .noCommand].shuffled()))"
    #expect(mods == "⌃⌥")
  }

  @Test
  func description_withCtrlShift_shouldBeCtrlShift() {
    let mods = "\(AXMenuItemModifiers([.control, .shift, .noCommand].shuffled()))"
    #expect(mods == "⌃⇧")
  }

  @Test
  func description_withOptShift_shouldBeOptShift() {
    let mods = "\(AXMenuItemModifiers([.option, .shift, .noCommand].shuffled()))"
    #expect(mods == "⌥⇧")
  }

  @Test
  func description_withBeCtrlOptShiftCmd_shouldBeCtrlOptShiftCmd() {
    let mods = "\(AXMenuItemModifiers([.shift, .control, .option].shuffled()))"
    #expect(mods == "⌃⌥⇧⌘")
  }

  @Test
  func description_withSingleModifierNoCommand_shouldSingleModifierNoCommand() {
    for item in [(AXMenuItemModifiers.control, "⌃"), (.shift, "⇧"), (.option, "⌥")] {
      #expect("\(item.0.union(.noCommand))" == item.1)
    }
  }

  @Test
  func description_withNoCommand_shouldBeEmpty() {
    let mods = "\(AXMenuItemModifiers([.noCommand]))"
    #expect(mods == "")
  }

  @Test
  func description_with0x18_shouldBeFn() {
    let mods = "\(AXMenuItemModifiers(rawValue: 0x18))"
    #expect(mods == "🌐")
  }
}
