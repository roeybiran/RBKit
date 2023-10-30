import Carbon
import Cocoa

// MARK: - KeyEvent

/// A wrapper around `NSEvent.KeyEvent`.
public struct KeyEvent: Equatable {
  let keyCode: UInt16
  let characters: String?
  let charactersIgnoringModifiers: String?
  let type: NSEvent.EventType
  let modifierFlags: NSEvent.ModifierFlags
  let isARepeat: Bool
}

extension KeyEvent {
  public init(
    keyCode: UInt16,
    characters: String,
    charactersIgnoringModifiers: String,
    type: NSEvent.EventType = .keyDown,
    modifiers: NSEvent.ModifierFlags = [],
    repeating: Bool = false)
  {
    self.keyCode = keyCode
    self.characters = characters
    self.charactersIgnoringModifiers = charactersIgnoringModifiers
    self.type = type
    modifierFlags = modifiers
    isARepeat = repeating
  }

  public init(event: NSEvent) {
    keyCode = event.keyCode
    characters = event.characters
    charactersIgnoringModifiers = event.charactersIgnoringModifiers
    type = event.type
    modifierFlags = event.modifierFlags
    isARepeat = event.isARepeat
  }
}

extension KeyEvent {
  public static func downArrow(modifiers: NSEvent.ModifierFlags = []) -> Self {
    KeyEvent(
      keyCode: UInt16(kVK_DownArrow),
      characters: "\(NSEvent.SpecialKey.downArrow.unicodeScalar)",
      charactersIgnoringModifiers: "\(NSEvent.SpecialKey.downArrow.unicodeScalar)",
      modifiers: modifiers)
  }

  public static func upArrow(modifiers: NSEvent.ModifierFlags = []) -> Self {
    KeyEvent(
      keyCode: UInt16(kVK_UpArrow),
      characters: "\(NSEvent.SpecialKey.upArrow.unicodeScalar)",
      charactersIgnoringModifiers: "\(NSEvent.SpecialKey.upArrow.unicodeScalar)",
      modifiers: modifiers)
  }

  public static func pageUp() -> Self {
    .init(
      keyCode: UInt16(kVK_PageUp),
      characters: NSEvent.SpecialKey.pageUp.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageUp.character,
      modifiers: .init(rawValue: 0x800100))
  }

  public static func pageDown() -> Self {
    .init(
      keyCode: UInt16(kVK_PageDown),
      characters: NSEvent.SpecialKey.pageDown.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageDown.character,
      modifiers: .init(rawValue: 0x800100))
  }

  public static func home() -> Self {
    .init(
      keyCode: UInt16(kVK_Home),
      characters: NSEvent.SpecialKey.home.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.home.character)
  }

  public static func end() -> Self {
    .init(
      keyCode: UInt16(kVK_End),
      characters: NSEvent.SpecialKey.end.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.end.character)
  }

}

extension NSEvent.SpecialKey {
  var character: String {
    "\(unicodeScalar)"
  }
}

extension NSView {
  public func keyDown(with event: KeyEvent) {
    guard
      let characters = event.characters,
      let charactersIgnoringModifiers = event.charactersIgnoringModifiers,
      let nsEvent = NSEvent.keyEvent(
        with: event.type,
        location: NSEvent.mouseLocation,
        modifierFlags: event.modifierFlags,
        timestamp: ProcessInfo.processInfo.systemUptime,
        windowNumber: window?.windowNumber ?? .zero,
        context: .current,
        characters: characters,
        charactersIgnoringModifiers: charactersIgnoringModifiers,
        isARepeat: event.isARepeat,
        keyCode: event.keyCode)
    else { return }

    keyDown(with: nsEvent)
  }
}
