import AppKit
import Testing

@testable import RBKit

@MainActor
@Suite
struct `NSEvent Value Tests` {
    @Test
    func `Init creates value for key down events`() {
        let event = NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
            timestamp: .zero,
            windowNumber: .zero,
            context: nil,
            characters: NSEvent.SpecialKey.downArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
            isARepeat: false,
            keyCode: UInt16(126)
        )!
        let actual = NSEventValue(nsEvent: event)
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.downArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
            keyCode: UInt16(126),
            specialKey: .downArrow,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Init creates value for key up events`() {
        let event = NSEvent.keyEvent(
            with: .keyUp,
            location: .zero,
            modifierFlags: .command,
            timestamp: .zero,
            windowNumber: .zero,
            context: nil,
            characters: NSEvent.SpecialKey.downArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
            isARepeat: false,
            keyCode: UInt16(126)
        )!
        let actual = NSEventValue(nsEvent: event)
        let expected = NSEventValue(
            type: .keyUp,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: .command,
            characters: NSEvent.SpecialKey.downArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
            keyCode: UInt16(126),
            specialKey: .downArrow,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Init ignores non key events`() {
        let event = NSEvent.keyEvent(
            with: .flagsChanged,
            location: .zero,
            modifierFlags: .command,
            timestamp: .zero,
            windowNumber: .zero,
            context: nil,
            characters: NSEvent.SpecialKey.downArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
            isARepeat: false,
            keyCode: UInt16(126)
        )!

        #expect(NSEventValue(nsEvent: event) == nil)
    }

    @Test
    func `Factory builds up arrow key`() {
        let actual = NSEventValue.upArrow()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.upArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.upArrow.character,
            keyCode: UInt16(126),
            specialKey: .upArrow,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds right arrow key`() {
        let actual = NSEventValue.rightArrow()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.rightArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.rightArrow.character,
            keyCode: UInt16(124),
            specialKey: .rightArrow,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds down arrow key`() {
        let actual = NSEventValue.downArrow()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.downArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
            keyCode: UInt16(125),
            specialKey: .downArrow,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds left arrow key`() {
        let actual = NSEventValue.leftArrow()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.leftArrow.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.leftArrow.character,
            keyCode: UInt16(123),
            specialKey: .leftArrow,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds page up key`() {
        let actual = NSEventValue.pageUp()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: .init(rawValue: 0x800100),
            characters: NSEvent.SpecialKey.pageUp.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.pageUp.character,
            keyCode: UInt16(116),
            specialKey: .pageUp,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds page down key`() {
        let actual = NSEventValue.pageDown()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: .init(rawValue: 0x800100),
            characters: NSEvent.SpecialKey.pageDown.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.pageDown.character,
            keyCode: UInt16(121),
            specialKey: .pageDown,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds home key`() {
        let actual = NSEventValue.home()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.home.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.home.character,
            keyCode: UInt16(115),
            specialKey: .home,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Factory builds end key`() {
        let actual = NSEventValue.end()
        let expected = NSEventValue(
            type: .keyDown,
            locationInWindow: .zero,
            timestamp: .zero,
            windowNumber: .zero,
            modifierFlags: [],
            characters: NSEvent.SpecialKey.end.character,
            charactersIgnoringModifiers: NSEvent.SpecialKey.end.character,
            keyCode: UInt16(119),
            specialKey: .end,
            isARepeat: false
        )

        #expect(actual == expected)
    }

    @Test
    func `Dot syntax settable updates key path`() {
        let field = NSTextField()
        field.set(\.stringValue, to: "foo")

        #expect(field.stringValue == "foo")
    }
}
