import AppKit

extension NSView {
  public func keyDown(with event: NSEventValue) {
    guard
      let nsEvent = NSEvent.keyEvent(
        with: event.type,
        location: NSEvent.mouseLocation,
        modifierFlags: event.modifierFlags,
        timestamp: event.timestamp,
        windowNumber: event.windowNumber,
        context: nil,
        characters: event.characters ?? "",
        charactersIgnoringModifiers: event.charactersIgnoringModifiers ?? "",
        isARepeat: event.isARepeat,
        keyCode: event.keyCode)
    else {
      return
    }

    keyDown(with: nsEvent)
  }
}
