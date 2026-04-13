import AppKit
import Carbon
import Testing
@testable import RBKit

@Test
func `modifiers description with all modifiers`() {
  let flags = NSEvent.ModifierFlags([.command, .control, .option, .shift].shuffled())
  let modifiers = Modifiers(cocoa: flags)
  #expect("\(modifiers)" == "⌃⌥⇧⌘")
}

@Test
func `init carbon should convert to cocoa modifiers`() {
  #expect(Modifiers(carbon: cmdKey).cocoa == .command)

  var modifiers = 0
  modifiers |= cmdKey
  modifiers |= shiftKey
  modifiers |= controlKey
  modifiers |= optionKey

  #expect(Modifiers(carbon: modifiers).cocoa == [.command, .shift, .control, .option])
}

@Test
func `init cocoa should convert to carbon modifiers`() {
  var modifiers = 0
  modifiers |= cmdKey
  modifiers |= shiftKey
  modifiers |= controlKey
  modifiers |= optionKey

  #expect(Modifiers(cocoa: [.command, .shift, .control, .option]).carbon == modifiers)
}

@Test
func `unsupported cocoa modifiers should be dropped`() {
  let modifiers = Modifiers(cocoa: [
    .command,
    .shift,
    .control,
    .option,
    .function,
    .capsLock,
    .numericPad,
  ])

  #expect(modifiers.cocoa == [.command, .shift, .control, .option])
}
