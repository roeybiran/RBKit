@preconcurrency import AppKit
import Carbon

// MARK: - NSEventValue

public struct NSEventValue {

  // MARK: Public

  // Getting mouse event information
  // -----------------------------
  // static var pressedMouseButtons: Int
  // static var doubleClickInterval: TimeInterval
  // static var mouseLocation: NSPoint
  // public let buttonNumber: Int
  // public let clickCount: Int
  // public let associatedEventsMask: NSEvent.EventTypeMask

  // Getting scroll wheel and flick events
  // -------------------------------------
  // public let deltaX: CGFloat
  // public let deltaY: CGFloat
  // public let deltaZ: CGFloat
  // public let hasPreciseScrollingDeltas: Bool
  // public let scrollingDeltaX: CGFloat
  // public let scrollingDeltaY: CGFloat
  // public let momentumPhase: NSEvent.Phase
  // public let isDirectionInvertedFromDevice: Bool

  // Configuring swipe event behaviors
  // ---------------------------------
  // static var isSwipeTrackingFromScrollEventsEnabled: Bool
  // func trackSwipeEvent(options: NSEvent.SwipeTrackingOptions = [], dampenAmountThresholdMin minDampenThreshold: CGFloat, max maxDampenThreshold: CGFloat, usingHandler trackingHandler: @escaping (CGFloat, NSEvent.Phase, Bool, UnsafeMutablePointer<ObjCBool>) -> Void)

  // Getting gesture and touch information
  // -------------------------------------
  // let context: NSGraphicsContext?
  // public let eventNumber: Int
  // public let pressure: Float
  // public let trackingNumber: Int
  // public let userData: UnsafeMutableRawPointer?
  // let trackingArea: NSTrackingArea? /
  // public let data1: Int
  // public let data2: Int
  // init?(eventRef: UnsafeRawPointer)
  // init?(cgEvent: CGEvent)
  // let var isMouseCoalescingEnabled: Bool
  // public let magnification: CGFloat
  // public let deviceID: Int
  // public let rotation: Float
  // public let absoluteX: Int
  // public let absoluteY: Int
  // public let absoluteZ: Int
  // public let buttonMask: NSEvent.ButtonMask
  // public let tilt: NSPoint
  // public let tangentialPressure: Float
  // let vendorDefined: Any
  // public let vendorID: Int
  // public let tabletID: Int
  // public let pointingDeviceID: Int
  // public let systemTabletID: Int
  // public let vendorPointingDeviceType: Int
  // public let pointingDeviceSerialNumber: Int
  // public let uniqueID: UInt64
  // public let capabilityMask: Int
  // public let pointingDeviceType: NSEvent.PointingDeviceType
  // public let isEnteringProximity: Bool
  // func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch>
  // func allTouches() -> Set<NSTouch>
  // func touches(for view: NSView) -> Set<NSTouch>
  // func coalescedTouches(for touch: NSTouch) -> [NSTouch]
  // public let phase: NSEvent.Phase
  // public let stage: Int
  // public let stageTransition: CGFloat
  // public let pressureBehavior: NSEvent.PressureBehavior
  // func startPeriodicEvents(afterDelay delay: TimeInterval, withPeriod period: TimeInterval)
  // func stopPeriodicEvents()
  // func mouseEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, eventNumber eNum: Int, clickCount cNum: Int, pressure: Float) -> NSEvent?
  // func keyEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, characters keys: String, charactersIgnoringModifiers ukeys: String, isARepeat flag: Bool, keyCode code: UInt16) -> NSEvent?
  // func enterExitEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, eventNumber eNum: Int, trackingNumber tNum: Int, userData data: UnsafeMutableRawPointer?) -> NSEvent?
  // func otherEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, subtype: Int16, data1 d1: Int, data2 d2: Int) -> NSEvent?

  /// Getting the event type
  /// ----------------------
  public let type: NSEvent.EventType
  // Getting general event information
  // ---------------------------------
  public let locationInWindow: NSPoint
  public let timestamp: TimeInterval
  public let windowNumber: Int

  /// Getting modifier flags
  /// ----------------------
  public let modifierFlags: NSEvent.ModifierFlags
  // public static let modifierFlags = NSEvent.modifierFlags

  // Getting key event information
  // -----------------------------
  public let characters: String?
  public let charactersIgnoringModifiers: String?
  public let keyCode: UInt16
  // func characters(byApplyingModifiers modifiers: NSEvent.ModifierFlags) -> String? {}
  // static var keyRepeatDelay: TimeInterval
  // static var keyRepeatInterval: TimeInterval
  public let specialKey: NSEvent.SpecialKey?
  public let isARepeat: Bool

  public static func upArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    keyDownEvent(
      character: "\(NSEvent.SpecialKey.upArrow.unicodeScalar)",
      code: kVK_UpArrow,
      modifierFlags: modifierFlags,
      specialKey: .upArrow
    )
  }

  public static func rightArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.rightArrow.character,
      code: kVK_RightArrow,
      modifierFlags: modifierFlags,
      specialKey: .rightArrow
    )
  }

  public static func downArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.downArrow.character,
      code: kVK_DownArrow,
      modifierFlags: modifierFlags,
      specialKey: .downArrow
    )
  }

  public static func leftArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.leftArrow.character,
      code: kVK_LeftArrow,
      modifierFlags: modifierFlags,
      specialKey: .leftArrow
    )
  }

  public static func pageUp() -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.pageUp.character,
      code: kVK_PageUp,
      modifierFlags: .init(rawValue: 0x800100),
      specialKey: .pageUp
    )
  }

  public static func pageDown() -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.pageDown.character,
      code: kVK_PageDown,
      modifierFlags: .init(rawValue: 0x800100),
      specialKey: .pageDown
    )
  }

  public static func home() -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.home.character,
      code: kVK_Home,
      modifierFlags: [],
      specialKey: .home
    )
  }

  public static func end() -> Self {
    keyDownEvent(
      character: NSEvent.SpecialKey.end.character,
      code: kVK_End,
      modifierFlags: [],
      specialKey: .end
    )
  }

  // MARK: Internal

  static func keyDownEvent(
    character: String,
    code: Int,
    modifierFlags: NSEvent.ModifierFlags,
    specialKey: NSEvent.SpecialKey? = nil
  ) -> Self {
    Self(
      type: .keyDown,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: modifierFlags,
      characters: character,
      charactersIgnoringModifiers: character,
      keyCode: UInt16(code),
      specialKey: specialKey,
      isARepeat: false
    )
  }

}

extension NSEventValue {
  public init?(nsEvent: NSEvent) {
    guard nsEvent.type == .keyDown || nsEvent.type == .keyUp else { return nil }
    type = nsEvent.type
    timestamp = nsEvent.timestamp
    windowNumber = nsEvent.windowNumber
    locationInWindow = nsEvent.locationInWindow
    modifierFlags = nsEvent.modifierFlags
    characters = nsEvent.characters // NSInternalInconsistencyException
    charactersIgnoringModifiers = nsEvent.charactersIgnoringModifiers // NSInternalInconsistencyException
    isARepeat = nsEvent.isARepeat // NSInternalInconsistencyException
    keyCode = nsEvent.keyCode // NSInternalInconsistencyException
    specialKey = nsEvent.specialKey
  }
}

// MARK: Equatable

extension NSEventValue: Equatable { }

// MARK: Sendable

extension NSEventValue: Sendable { }

#if DEBUG
extension NSEventValue {
  public static func mock(
    _ keyCode: UInt16?,
    _ modifierFlags: NSEvent.ModifierFlags = [],
    _ type: NSEvent.EventType = .keyDown
  ) -> Self {
    Self(
      type: type,
      locationInWindow: .zero,
      timestamp: .zero,
      windowNumber: .zero,
      modifierFlags: modifierFlags,
      characters: nil,
      charactersIgnoringModifiers: nil,
      keyCode: keyCode ?? 0,
      specialKey: nil,
      isARepeat: false
    )
  }
}
#endif
