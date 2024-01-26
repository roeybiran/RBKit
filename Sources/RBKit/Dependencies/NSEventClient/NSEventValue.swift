import AppKit
import Carbon

public struct NSEventValue {
  public let type: NSEvent.EventType
  public let modifierFlags: NSEvent.ModifierFlags
  public let timestamp: TimeInterval
  // weak let window: NSWindow?
  public let windowNumber: Int
  // let context: NSGraphicsContext?
  public let clickCount: Int
  public let buttonNumber: Int
  public let eventNumber: Int
  public let pressure: Float
  public let locationInWindow: NSPoint
  public let deltaX: CGFloat
  public let deltaY: CGFloat
  public let deltaZ: CGFloat
  public let hasPreciseScrollingDeltas: Bool
  public let scrollingDeltaX: CGFloat
  public let scrollingDeltaY: CGFloat
  public let momentumPhase: NSEvent.Phase
  public let isDirectionInvertedFromDevice: Bool
  public let characters: String?
  public let charactersIgnoringModifiers: String?
  // let characters(byApplyingModifiers modifiers: NSEvent.ModifierFlags) -> String?
  public let isARepeat: Bool
  public let keyCode: UInt16
  public let trackingNumber: Int
  public let userData: UnsafeMutableRawPointer?
  // let trackingArea: NSTrackingArea? /
  public let subtype: NSEvent.EventSubtype
  public let data1: Int
  public let data2: Int
  // let eventRef: UnsafeRawPointer?  /* EventRef */
  // init?(eventRef: UnsafeRawPointer)
  // let cgEvent: CGEvent?
  // init?(cgEvent: CGEvent)
  // let var isMouseCoalescingEnabled: Bool
  public let magnification: CGFloat
  public let deviceID: Int
  public let rotation: Float
  public let absoluteX: Int
  public let absoluteY: Int
  public let absoluteZ: Int
  public let buttonMask: NSEvent.ButtonMask
  public let tilt: NSPoint
  public let tangentialPressure: Float
  // let vendorDefined: Any
  public let vendorID: Int
  public let tabletID: Int
  public let pointingDeviceID: Int
  public let systemTabletID: Int
  public let vendorPointingDeviceType: Int
  public let pointingDeviceSerialNumber: Int
  public let uniqueID: UInt64
  public let capabilityMask: Int
  public let pointingDeviceType: NSEvent.PointingDeviceType
  public let isEnteringProximity: Bool
  // func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch>
  // func allTouches() -> Set<NSTouch>
  // func touches(for view: NSView) -> Set<NSTouch>
  // func coalescedTouches(for touch: NSTouch) -> [NSTouch]
  public let phase: NSEvent.Phase
  public let stage: Int
  public let stageTransition: CGFloat
  public let associatedEventsMask: NSEvent.EventTypeMask
  public let pressureBehavior: NSEvent.PressureBehavior
  // static var isSwipeTrackingFromScrollEventsEnabled: Bool
  // func trackSwipeEvent(options: NSEvent.SwipeTrackingOptions = [], dampenAmountThresholdMin minDampenThreshold: CGFloat, max maxDampenThreshold: CGFloat, usingHandler trackingHandler: @escaping (CGFloat, NSEvent.Phase, Bool, UnsafeMutablePointer<ObjCBool>) -> Void)
  // func startPeriodicEvents(afterDelay delay: TimeInterval, withPeriod period: TimeInterval)
  // func stopPeriodicEvents()
  // func mouseEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, eventNumber eNum: Int, clickCount cNum: Int, pressure: Float) -> NSEvent?
  // func keyEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, characters keys: String, charactersIgnoringModifiers ukeys: String, isARepeat flag: Bool, keyCode code: UInt16) -> NSEvent?
  // func enterExitEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, eventNumber eNum: Int, trackingNumber tNum: Int, userData data: UnsafeMutableRawPointer?) -> NSEvent?
  // func otherEvent(with type: NSEvent.EventType, location: NSPoint, modifierFlags flags: NSEvent.ModifierFlags, timestamp time: TimeInterval, windowNumber wNum: Int, context unusedPassNil: NSGraphicsContext?, subtype: Int16, data1 d1: Int, data2 d2: Int) -> NSEvent?
  // static var mouseLocation: NSPoint
  // static var modifierFlags: NSEvent.ModifierFlags
  // static var pressedMouseButtons: Int
  // static var doubleClickInterval: TimeInterval
  // static var keyRepeatDelay: TimeInterval
  // static var keyRepeatInterval: TimeInterval
  public let specialKey: NSEvent.SpecialKey?


  public static func downArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    Self(
      modifierFlags: modifierFlags,
      characters: "\(NSEvent.SpecialKey.downArrow.unicodeScalar)",
      charactersIgnoringModifiers: "\(NSEvent.SpecialKey.downArrow.unicodeScalar)",
      keyCode: UInt16(kVK_DownArrow)
    )
  }

  public static func upArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    Self(
      modifierFlags: modifierFlags,
      characters: "\(NSEvent.SpecialKey.upArrow.unicodeScalar)",
      charactersIgnoringModifiers: "\(NSEvent.SpecialKey.upArrow.unicodeScalar)",
      keyCode: UInt16(kVK_UpArrow)
    )
  }

  public static func pageUp() -> Self {
    Self(
      modifierFlags: .init(rawValue: 0x800100),
      characters: NSEvent.SpecialKey.pageUp.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageUp.character,
      keyCode: UInt16(kVK_PageUp)
    )
  }

  public static func pageDown() -> Self {
    Self(
      modifierFlags: .init(rawValue: 0x800100),
      characters: NSEvent.SpecialKey.pageDown.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageDown.character,
      keyCode: UInt16(kVK_PageDown)
    )
  }

  public static func home() -> Self {
    Self(
      characters: NSEvent.SpecialKey.home.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.home.character,
      keyCode: UInt16(kVK_Home)
    )
  }

  public static func end() -> Self {
    Self(
      characters: NSEvent.SpecialKey.end.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.end.character,
      keyCode: UInt16(kVK_End)
    )
  }



}

extension NSEventValue {
  init(nsEvent: NSEvent) {
    type = nsEvent.type
    modifierFlags = nsEvent.modifierFlags
    timestamp = nsEvent.timestamp
    windowNumber = nsEvent.windowNumber
    clickCount = nsEvent.clickCount
    buttonNumber = nsEvent.buttonNumber
    eventNumber = nsEvent.eventNumber
    pressure = nsEvent.pressure
    locationInWindow = nsEvent.locationInWindow
    deltaX = nsEvent.deltaX
    deltaY = nsEvent.deltaY
    deltaZ = nsEvent.deltaZ
    hasPreciseScrollingDeltas = nsEvent.hasPreciseScrollingDeltas
    scrollingDeltaX = nsEvent.scrollingDeltaX
    scrollingDeltaY = nsEvent.scrollingDeltaY
    momentumPhase = nsEvent.momentumPhase
    isDirectionInvertedFromDevice = nsEvent.isDirectionInvertedFromDevice
    characters = nsEvent.characters
    charactersIgnoringModifiers = nsEvent.charactersIgnoringModifiers
    isARepeat = nsEvent.isARepeat
    keyCode = nsEvent.keyCode
    trackingNumber = nsEvent.trackingNumber
    userData = nsEvent.userData
    subtype = nsEvent.subtype
    data1 = nsEvent.data1
    data2 = nsEvent.data2
    magnification = nsEvent.magnification
    deviceID = nsEvent.deviceID
    rotation = nsEvent.rotation
    absoluteX = nsEvent.absoluteX
    absoluteY = nsEvent.absoluteY
    absoluteZ = nsEvent.absoluteZ
    buttonMask = nsEvent.buttonMask
    tilt = nsEvent.tilt
    tangentialPressure = nsEvent.tangentialPressure
    vendorID = nsEvent.vendorID
    tabletID = nsEvent.tabletID
    pointingDeviceID = nsEvent.pointingDeviceID
    systemTabletID = nsEvent.systemTabletID
    vendorPointingDeviceType = nsEvent.vendorPointingDeviceType
    pointingDeviceSerialNumber = nsEvent.pointingDeviceSerialNumber
    uniqueID = nsEvent.uniqueID
    capabilityMask = nsEvent.capabilityMask
    pointingDeviceType = nsEvent.pointingDeviceType
    isEnteringProximity = nsEvent.isEnteringProximity
    phase = nsEvent.phase
    stage = nsEvent.stage
    stageTransition = nsEvent.stageTransition
    associatedEventsMask = nsEvent.associatedEventsMask
    pressureBehavior = nsEvent.pressureBehavior
    specialKey = nsEvent.specialKey
  }

  init(
    _type: NSEvent.EventType = .keyDown,
    modifierFlags: NSEvent.ModifierFlags = [],
    timestamp: TimeInterval = .zero,
    windowNumber: Int = .zero,
    clickCount: Int = .zero,
    buttonNumber: Int = .zero,
    eventNumber: Int = .zero,
    pressure: Float = .zero,
    locationInWindow: NSPoint = .zero,
    deltaX: CGFloat = .zero,
    deltaY: CGFloat = .zero,
    deltaZ: CGFloat = .zero,
    hasPreciseScrollingDeltas: Bool = false,
    scrollingDeltaX: CGFloat = .zero,
    scrollingDeltaY: CGFloat = .zero,
    momentumPhase: NSEvent.Phase = .began,
    isDirectionInvertedFromDevice: Bool = false,
    characters: String? = nil,
    charactersIgnoringModifiers: String? = nil,
    isARepeat: Bool = false,
    keyCode: UInt16 = .zero,
    trackingNumber: Int = .zero,
    userData: UnsafeMutableRawPointer? = nil,
    subtype: NSEvent.EventSubtype = .applicationActivated,
    data1: Int = .zero,
    data2: Int = .zero,
    magnification: CGFloat = .zero,
    deviceID: Int = .zero,
    rotation: Float = .zero,
    absoluteX: Int = .zero,
    absoluteY: Int = .zero,
    absoluteZ: Int = .zero,
    buttonMask: NSEvent.ButtonMask = .penLowerSide,
    tilt: NSPoint = .zero,
    tangentialPressure: Float = .zero,
    vendorID: Int = .zero,
    tabletID: Int = .zero,
    pointingDeviceID: Int = .zero,
    systemTabletID: Int = .zero,
    vendorPointingDeviceType: Int = .zero,
    pointingDeviceSerialNumber: Int = .zero,
    uniqueID: UInt64 = .zero,
    capabilityMask: Int = .zero,
    pointingDeviceType: NSEvent.PointingDeviceType = .cursor,
    isEnteringProximity: Bool = false,
    phase: NSEvent.Phase = .began,
    stage: Int = .zero,
    stageTransition: CGFloat = .zero,
    associatedEventsMask: NSEvent.EventTypeMask = .appKitDefined,
    pressureBehavior: NSEvent.PressureBehavior = .primaryAccelerator,
    specialKey: NSEvent.SpecialKey? = nil
  ) {
    self.type = _type
    self.modifierFlags = modifierFlags
    self.timestamp = timestamp
    self.windowNumber = windowNumber
    self.clickCount = clickCount
    self.buttonNumber = buttonNumber
    self.eventNumber = eventNumber
    self.pressure = pressure
    self.locationInWindow = locationInWindow
    self.deltaX = deltaX
    self.deltaY = deltaY
    self.deltaZ = deltaZ
    self.hasPreciseScrollingDeltas = hasPreciseScrollingDeltas
    self.scrollingDeltaX = scrollingDeltaX
    self.scrollingDeltaY = scrollingDeltaY
    self.momentumPhase = momentumPhase
    self.isDirectionInvertedFromDevice = isDirectionInvertedFromDevice
    self.characters = characters
    self.charactersIgnoringModifiers = charactersIgnoringModifiers
    self.isARepeat = isARepeat
    self.keyCode = keyCode
    self.trackingNumber = trackingNumber
    self.userData = userData
    self.subtype = subtype
    self.data1 = data1
    self.data2 = data2
    self.magnification = magnification
    self.deviceID = deviceID
    self.rotation = rotation
    self.absoluteX = absoluteX
    self.absoluteY = absoluteY
    self.absoluteZ = absoluteZ
    self.buttonMask = buttonMask
    self.tilt = tilt
    self.tangentialPressure = tangentialPressure
    self.vendorID = vendorID
    self.tabletID = tabletID
    self.pointingDeviceID = pointingDeviceID
    self.systemTabletID = systemTabletID
    self.vendorPointingDeviceType = vendorPointingDeviceType
    self.pointingDeviceSerialNumber = pointingDeviceSerialNumber
    self.uniqueID = uniqueID
    self.capabilityMask = capabilityMask
    self.pointingDeviceType = pointingDeviceType
    self.isEnteringProximity = isEnteringProximity
    self.phase = phase
    self.stage = stage
    self.stageTransition = stageTransition
    self.associatedEventsMask = associatedEventsMask
    self.pressureBehavior = pressureBehavior
    self.specialKey = specialKey
  }
}

// MARK: Equatable

extension NSEventValue: Equatable {}
