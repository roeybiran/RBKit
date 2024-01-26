import AppKit

#if DEBUG
extension NSEventValue {
  public static func mock(
    _ keyCode: Int,
    _ modifierFlags: NSEvent.ModifierFlags = [],
    _ type: NSEvent.EventType = .keyDown
  )
  -> Self
  {
    NSEventValue(
      type: type,
      modifierFlags: modifierFlags,
      timestamp: .zero,
      windowNumber: .zero,
      clickCount: .zero,
      buttonNumber: .zero,
      eventNumber: .zero,
      pressure: .zero,
      locationInWindow: .zero,
      deltaX: .zero,
      deltaY: .zero,
      deltaZ: .zero,
      hasPreciseScrollingDeltas: false,
      scrollingDeltaX: .zero,
      scrollingDeltaY: .zero,
      momentumPhase: .began,
      isDirectionInvertedFromDevice: false,
      characters: nil,
      charactersIgnoringModifiers: nil,
      isARepeat: false,
      keyCode: UInt16(keyCode),
      trackingNumber: .zero,
      userData: nil,
      subtype: .applicationActivated,
      data1: .zero,
      data2: .zero,
      magnification: .zero,
      deviceID: .zero,
      rotation: .zero,
      absoluteX: .zero,
      absoluteY: .zero,
      absoluteZ: .zero,
      buttonMask: .penLowerSide,
      tilt: .zero,
      tangentialPressure: .zero,
      vendorID: .zero,
      tabletID: .zero,
      pointingDeviceID: .zero,
      systemTabletID: .zero,
      vendorPointingDeviceType: .zero,
      pointingDeviceSerialNumber: .zero,
      uniqueID: .zero,
      capabilityMask: .zero,
      pointingDeviceType: .cursor,
      isEnteringProximity: false,
      phase: .began,
      stage: .zero,
      stageTransition: .zero,
      associatedEventsMask: .appKitDefined,
      pressureBehavior: .primaryAccelerator,
      specialKey: nil
    )
  }
}
#endif

