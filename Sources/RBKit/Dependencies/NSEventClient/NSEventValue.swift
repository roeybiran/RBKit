@preconcurrency import AppKit
import Carbon

// MARK: - NSEventValue

public struct NSEventValue {

  // MARK: Lifecycle

  public init(nsEvent: NSEvent) {
    type = nsEvent.type
    locationInWindow = nsEvent.locationInWindow
    timestamp = nsEvent.timestamp
    windowNumber = nsEvent.windowNumber
    modifierFlags = nsEvent.modifierFlags

    switch nsEvent.type {
    case .keyDown, .keyUp:
      eventType = .key(
        .init(
          characters: nsEvent.characters,
          charactersIgnoringModifiers: nsEvent.charactersIgnoringModifiers,
          keyCode: nsEvent.keyCode,
          specialKey: nsEvent.specialKey,
          isARepeat: nsEvent.isARepeat,
        )
      )

    case .scrollWheel:
      eventType = .scrollWheel(
        .init(
          deltaX: nsEvent.deltaX,
          deltaY: nsEvent.deltaY,
          deltaZ: nsEvent.deltaZ,
          hasPreciseScrollingDeltas: nsEvent.hasPreciseScrollingDeltas,
          scrollingDeltaX: nsEvent.scrollingDeltaX,
          scrollingDeltaY: nsEvent.scrollingDeltaY,
          phase: nsEvent.phase,
          momentumPhase: nsEvent.momentumPhase,
          isDirectionInvertedFromDevice: nsEvent.isDirectionInvertedFromDevice,
        )
      )

    case
      .leftMouseDown,
      .leftMouseUp,
      .leftMouseDragged,
      .rightMouseDown,
      .rightMouseUp,
      .rightMouseDragged,
      .otherMouseDown,
      .otherMouseUp,
      .otherMouseDragged:
      eventType = .mouse(
        .init(
          buttonNumber: nsEvent.buttonNumber,
          clickCount: nsEvent.clickCount,
          eventNumber: nsEvent.eventNumber,
          pressure: nsEvent.pressure,
        )
      )

    default:
      eventType = .other
    }
  }

  init(
    type: NSEvent.EventType,
    locationInWindow: NSPoint,
    timestamp: TimeInterval,
    windowNumber: Int,
    modifierFlags: NSEvent.ModifierFlags,
    eventType: EventType,
  ) {
    self.type = type
    self.locationInWindow = locationInWindow
    self.timestamp = timestamp
    self.windowNumber = windowNumber
    self.modifierFlags = modifierFlags
    self.eventType = eventType
  }

  // MARK: Public

  public enum EventType {
    case key(KeyEvent)
    case mouse(MouseEvent)
    case scrollWheel(ScrollWheelEvent)
    case other
  }

  public struct KeyEvent {
    public let characters: String?
    public let charactersIgnoringModifiers: String?
    public let keyCode: UInt16
    public let specialKey: NSEvent.SpecialKey?
    public let isARepeat: Bool
  }

  public struct MouseEvent {
    public let buttonNumber: Int
    public let clickCount: Int
    public let eventNumber: Int
    public let pressure: Float
  }

  public struct ScrollWheelEvent {
    public let deltaX: CGFloat
    public let deltaY: CGFloat
    public let deltaZ: CGFloat
    public let hasPreciseScrollingDeltas: Bool
    public let scrollingDeltaX: CGFloat
    public let scrollingDeltaY: CGFloat
    public let phase: NSEvent.Phase
    public let momentumPhase: NSEvent.Phase
    public let isDirectionInvertedFromDevice: Bool
  }

  public let type: NSEvent.EventType
  public let locationInWindow: NSPoint
  public let timestamp: TimeInterval
  public let windowNumber: Int
  public let modifierFlags: NSEvent.ModifierFlags
  public let eventType: EventType

  public static func key(
    type: NSEvent.EventType = .keyDown,
    locationInWindow: NSPoint = .zero,
    timestamp: TimeInterval = .zero,
    windowNumber: Int = .zero,
    modifierFlags: NSEvent.ModifierFlags = [],
    characters: String? = nil,
    charactersIgnoringModifiers: String? = nil,
    keyCode: UInt16,
    specialKey: NSEvent.SpecialKey? = nil,
    isARepeat: Bool = false,
  ) -> Self {
    Self(
      type: type,
      locationInWindow: locationInWindow,
      timestamp: timestamp,
      windowNumber: windowNumber,
      modifierFlags: modifierFlags,
      eventType: .key(
        .init(
          characters: characters,
          charactersIgnoringModifiers: charactersIgnoringModifiers,
          keyCode: keyCode,
          specialKey: specialKey,
          isARepeat: isARepeat,
        )
      ),
    )
  }

  public static func mouse(
    type: NSEvent.EventType,
    locationInWindow: NSPoint = .zero,
    timestamp: TimeInterval = .zero,
    windowNumber: Int = .zero,
    modifierFlags: NSEvent.ModifierFlags = [],
    buttonNumber: Int = .zero,
    clickCount: Int = .zero,
    eventNumber: Int = .zero,
    pressure: Float = .zero,
  ) -> Self {
    Self(
      type: type,
      locationInWindow: locationInWindow,
      timestamp: timestamp,
      windowNumber: windowNumber,
      modifierFlags: modifierFlags,
      eventType: .mouse(
        .init(
          buttonNumber: buttonNumber,
          clickCount: clickCount,
          eventNumber: eventNumber,
          pressure: pressure,
        )
      ),
    )
  }

  public static func scrollWheel(
    locationInWindow: NSPoint = .zero,
    timestamp: TimeInterval = .zero,
    windowNumber: Int = .zero,
    modifierFlags: NSEvent.ModifierFlags = [],
    deltaX: CGFloat = .zero,
    deltaY: CGFloat = .zero,
    deltaZ: CGFloat = .zero,
    hasPreciseScrollingDeltas: Bool = false,
    scrollingDeltaX: CGFloat = .zero,
    scrollingDeltaY: CGFloat = .zero,
    phase: NSEvent.Phase = [],
    momentumPhase: NSEvent.Phase = [],
    isDirectionInvertedFromDevice: Bool = false,
  ) -> Self {
    Self(
      type: .scrollWheel,
      locationInWindow: locationInWindow,
      timestamp: timestamp,
      windowNumber: windowNumber,
      modifierFlags: modifierFlags,
      eventType: .scrollWheel(
        .init(
          deltaX: deltaX,
          deltaY: deltaY,
          deltaZ: deltaZ,
          hasPreciseScrollingDeltas: hasPreciseScrollingDeltas,
          scrollingDeltaX: scrollingDeltaX,
          scrollingDeltaY: scrollingDeltaY,
          phase: phase,
          momentumPhase: momentumPhase,
          isDirectionInvertedFromDevice: isDirectionInvertedFromDevice,
        )
      ),
    )
  }

  public static func other(
    type: NSEvent.EventType,
    locationInWindow: NSPoint = .zero,
    timestamp: TimeInterval = .zero,
    windowNumber: Int = .zero,
    modifierFlags: NSEvent.ModifierFlags = [],
  ) -> Self {
    Self(
      type: type,
      locationInWindow: locationInWindow,
      timestamp: timestamp,
      windowNumber: windowNumber,
      modifierFlags: modifierFlags,
      eventType: .other,
    )
  }

  public static func upArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    key(
      modifierFlags: modifierFlags,
      characters: NSEvent.SpecialKey.upArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.upArrow.character,
      keyCode: UInt16(kVK_UpArrow),
      specialKey: .upArrow,
    )
  }

  public static func rightArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    key(
      modifierFlags: modifierFlags,
      characters: NSEvent.SpecialKey.rightArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.rightArrow.character,
      keyCode: UInt16(kVK_RightArrow),
      specialKey: .rightArrow,
    )
  }

  public static func downArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    key(
      modifierFlags: modifierFlags,
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(kVK_DownArrow),
      specialKey: .downArrow,
    )
  }

  public static func leftArrow(modifierFlags: NSEvent.ModifierFlags = []) -> Self {
    key(
      modifierFlags: modifierFlags,
      characters: NSEvent.SpecialKey.leftArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.leftArrow.character,
      keyCode: UInt16(kVK_LeftArrow),
      specialKey: .leftArrow,
    )
  }

  public static func pageUp() -> Self {
    key(
      modifierFlags: .init(rawValue: 0x800100),
      characters: NSEvent.SpecialKey.pageUp.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageUp.character,
      keyCode: UInt16(kVK_PageUp),
      specialKey: .pageUp,
    )
  }

  public static func pageDown() -> Self {
    key(
      modifierFlags: .init(rawValue: 0x800100),
      characters: NSEvent.SpecialKey.pageDown.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.pageDown.character,
      keyCode: UInt16(kVK_PageDown),
      specialKey: .pageDown,
    )
  }

  public static func home() -> Self {
    key(
      characters: NSEvent.SpecialKey.home.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.home.character,
      keyCode: UInt16(kVK_Home),
      specialKey: .home,
    )
  }

  public static func end() -> Self {
    key(
      characters: NSEvent.SpecialKey.end.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.end.character,
      keyCode: UInt16(kVK_End),
      specialKey: .end,
    )
  }
}

// MARK: Equatable

extension NSEventValue: Equatable { }
extension NSEventValue.EventType: Equatable { }
extension NSEventValue.KeyEvent: Equatable { }
extension NSEventValue.MouseEvent: Equatable { }
extension NSEventValue.ScrollWheelEvent: Equatable { }

// MARK: Sendable

extension NSEventValue: Sendable { }
extension NSEventValue.EventType: Sendable { }
extension NSEventValue.KeyEvent: Sendable { }
extension NSEventValue.MouseEvent: Sendable { }
extension NSEventValue.ScrollWheelEvent: Sendable { }

#if DEBUG
extension NSEventValue {
  public static func mock(
    _ keyCode: UInt16?,
    _ modifierFlags: NSEvent.ModifierFlags = [],
    _ type: NSEvent.EventType = .keyDown,
  ) -> Self {
    key(
      type: type,
      modifierFlags: modifierFlags,
      keyCode: keyCode ?? 0,
    )
  }
}
#endif
