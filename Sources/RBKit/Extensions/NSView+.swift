import AppKit
import SwiftUI

extension NSView {

  // MARK: Public

  public enum ConstraintType {
    case pinningToEdges
    case pinningHorizontally(constant: CGFloat)
    case pinningToCenter
  }

  public enum Offset {
    case individual(horizontal: CGFloat, vertical: CGFloat)
    case uniform(CGFloat)
  }

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

  public func constraints(
    for type: ConstraintType,
    of otherView: NSView,
    offset: Offset = .uniform(0))
    -> [NSLayoutConstraint]
  {
    let verticalOffset: CGFloat
    let horizontalOffset: CGFloat
    switch offset {
    case .individual(let horizontal, let vertical):
      horizontalOffset = horizontal
      verticalOffset = vertical

    case .uniform(let offset):
      verticalOffset = offset
      horizontalOffset = offset
    }

    switch type {
    case .pinningToEdges:
      return [
        topAnchor.constraint(equalTo: otherView.topAnchor, constant: verticalOffset),
        trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -horizontalOffset),
        bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: -verticalOffset),
        leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: horizontalOffset),
      ]

    case .pinningToCenter:
      return [
        centerXAnchor.constraint(equalTo: otherView.centerXAnchor),
        centerYAnchor.constraint(equalTo: otherView.centerYAnchor),
      ]

    case .pinningHorizontally(let constant):
      return [
        widthAnchor.constraint(equalTo: otherView.widthAnchor, constant: constant),
        centerXAnchor.constraint(equalTo: otherView.centerXAnchor),
      ]
    }
  }

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
