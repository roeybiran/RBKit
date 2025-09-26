import Carbon
import AppKit
import Testing

@testable import RBKit

@Suite
struct `NSEvent.ModifierFlags Extensions Tests` {
    @Test
    func `Init with carbon flags`() throws {
        #expect(NSEvent.ModifierFlags(carbon: cmdKey) == .command)

        var modifiers = 0
        modifiers |= cmdKey
        modifiers |= shiftKey
        modifiers |= controlKey
        modifiers |= optionKey

        #expect(NSEvent.ModifierFlags(carbon: modifiers) == [.command, .shift, .control, .option])
    }

    @Test
    func `Carbonized flag round trip`() throws {
        var modifiers = 0
        modifiers |= cmdKey
        modifiers |= shiftKey
        modifiers |= controlKey
        modifiers |= optionKey

        #expect(NSEvent.ModifierFlags([.command, .shift, .control, .option]).carbonized == modifiers)
    }

    @Test
    func `Hot key applicable drops unsupported modifiers`() throws {
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
    func `Description renders symbols`() throws {
        let modifiers = NSEvent.ModifierFlags([.command, .shift, .control, .option].shuffled())

        #expect("\(modifiers)" == "⌃⌥⇧⌘")
    }
}
