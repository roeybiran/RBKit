import AppKit
import Testing

@testable import RBKit

@MainActor
@Suite
struct `NSEventValue Tests` {
    @Test
    func `init nsEvent:, with keyDown event, should create value`() async throws {
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
    func `init nsEvent:, with keyUp event, should create value`() async throws {
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
    func `init nsEvent:, with non-key event, should return nil`() async throws {
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
    func `upArrow, should create up arrow key event`() async throws {
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
    func `rightArrow, should create right arrow key event`() async throws {
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
    func `downArrow, should create down arrow key event`() async throws {
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
    func `leftArrow, should create left arrow key event`() async throws {
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
    func `pageUp, should create page up key event`() async throws {
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
    func `pageDown, should create page down key event`() async throws {
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
    func `home, should create home key event`() async throws {
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
    func `end, should create end key event`() async throws {
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
    func `set, with keyPath, should update value`() async throws {
        let field = NSTextField()
        field.set(\.stringValue, to: "foo")

        #expect(field.stringValue == "foo")
    }
}
