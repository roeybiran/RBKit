import AppKit
import Carbon
import Testing

@testable import RBKit

@Suite
struct `NSEvent.ModifierFlags Tests` {
  @Test
  func `init carbon:, with carbon flags, should convert to ModifierFlags`() {
    #expect(NSEvent.ModifierFlags(carbon: cmdKey) == .command)

    var modifiers = 0
    modifiers |= cmdKey
    modifiers |= shiftKey
    modifiers |= controlKey
    modifiers |= optionKey

    #expect(NSEvent.ModifierFlags(carbon: modifiers) == [.command, .shift, .control, .option])
  }

  @Test
  func `carbonized, should convert to carbon flags`() {
    var modifiers = 0
    modifiers |= cmdKey
    modifiers |= shiftKey
    modifiers |= controlKey
    modifiers |= optionKey

    #expect(NSEvent.ModifierFlags([.command, .shift, .control, .option]).carbonized == modifiers)
  }

  @Test
  func `hotkeyApplicable, with unsupported modifiers, should drop them`() {
    let modifiers = NSEvent.ModifierFlags([
      .command,
      .shift,
      .control,
      .option,
      .function,
      .capsLock,
      .numericPad,
    ])

    #expect(modifiers.hotkeyApplicable == [.command, .shift, .control, .option])
  }

  @Test
  func `description, should render symbols in correct order`() {
    let modifiers = NSEvent.ModifierFlags([.command, .shift, .control, .option].shuffled())

    #expect("\(modifiers)" == "⌃⌥⇧⌘")
  }
}
