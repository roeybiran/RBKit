import AppKit
import SwiftUI

extension NSView {
  public static var supplementaryViewKind: String {
    userInterfaceIdentifier.rawValue
  }

  public func enumerateSubviews(using handler: (NSView) -> Void) {
    for subview in subviews {
      handler(subview)
      subview.enumerateSubviews(using: handler)
    }
  }

  /// https://stackoverflow.com/questions/41386423/get-image-from-calayer-or-nsview-swift-3
  public func image() -> NSImage? {
    let imageRep = bitmapImageRepForCachingDisplay(in: bounds)
    if let imageRep {
      cacheDisplay(in: bounds, to: imageRep)
      let data = imageRep.representation(using: .jpeg, properties: [:])
      if let data {
        return NSImage(data: data)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }

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

extension NSView {

  // MARK: Public

  public func asPreview() -> some View {
    Preview(view: self)
  }

  // MARK: Private

  private struct Preview: NSViewRepresentable {
    let view: NSView

    func makeNSView(context _: Context) -> NSView {
      view
    }

    func updateNSView(_: NSView, context _: Context) { }
  }
}
