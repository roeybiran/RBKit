import AppKit

extension NSView {
  public func keyDown(with event: NSEventValue) {
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
