import AppKit
import SwiftUI

extension NSView {

  public enum ConstraintType {
    case pinningToEdges
    case pinningHorizontally(constant: CGFloat)
    case pinningToCenter
  }

  public enum Offset {
    case individual(horizontal: CGFloat, vertical: CGFloat)
    case uniform(CGFloat)
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
        keyCode: event.keyCode
      )
    else {
      return
    }

    keyDown(with: nsEvent)
  }

  public func constraints(
    for type: ConstraintType,
    of otherView: NSView,
    offset: Offset = .uniform(0)
  ) -> [NSLayoutConstraint] {
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
}
