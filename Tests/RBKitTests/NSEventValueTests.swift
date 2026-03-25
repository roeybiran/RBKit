import AppKit
import Carbon
import RBKitTestSupport
import Testing

@testable import RBKit

private final class AccessTrackingEvent: NSEvent.Mock {
  private(set) var accessedEventSpecificProperties = [String]()

  override var clickCount: Int {
    accessedEventSpecificProperties.append("clickCount")
    return super.clickCount
  }

  override var buttonNumber: Int {
    accessedEventSpecificProperties.append("buttonNumber")
    return super.buttonNumber
  }

  override var eventNumber: Int {
    accessedEventSpecificProperties.append("eventNumber")
    return super.eventNumber
  }

  override var pressure: Float {
    accessedEventSpecificProperties.append("pressure")
    return super.pressure
  }

  override var deltaX: CGFloat {
    accessedEventSpecificProperties.append("deltaX")
    return super.deltaX
  }

  override var deltaY: CGFloat {
    accessedEventSpecificProperties.append("deltaY")
    return super.deltaY
  }

  override var deltaZ: CGFloat {
    accessedEventSpecificProperties.append("deltaZ")
    return super.deltaZ
  }

  override var hasPreciseScrollingDeltas: Bool {
    accessedEventSpecificProperties.append("hasPreciseScrollingDeltas")
    return super.hasPreciseScrollingDeltas
  }

  override var scrollingDeltaX: CGFloat {
    accessedEventSpecificProperties.append("scrollingDeltaX")
    return super.scrollingDeltaX
  }

  override var scrollingDeltaY: CGFloat {
    accessedEventSpecificProperties.append("scrollingDeltaY")
    return super.scrollingDeltaY
  }

  override var phase: NSEvent.Phase {
    accessedEventSpecificProperties.append("phase")
    return super.phase
  }

  override var momentumPhase: NSEvent.Phase {
    accessedEventSpecificProperties.append("momentumPhase")
    return super.momentumPhase
  }

  override var isDirectionInvertedFromDevice: Bool {
    accessedEventSpecificProperties.append("isDirectionInvertedFromDevice")
    return super.isDirectionInvertedFromDevice
  }

  override var characters: String? {
    accessedEventSpecificProperties.append("characters")
    return super.characters
  }

  override var charactersIgnoringModifiers: String? {
    accessedEventSpecificProperties.append("charactersIgnoringModifiers")
    return super.charactersIgnoringModifiers
  }

  override var isARepeat: Bool {
    accessedEventSpecificProperties.append("isARepeat")
    return super.isARepeat
  }

  override var keyCode: UInt16 {
    accessedEventSpecificProperties.append("keyCode")
    return super.keyCode
  }
}

@MainActor
struct NSEventValueTests {
  @Test
  func `init nsEvent with keyDown event should create key payload`() throws {
    let event = try #require(NSEvent.keyEvent(
      with: .keyDown,
      location: .zero,
      modifierFlags: [],
      timestamp: .zero,
      windowNumber: .zero,
      context: nil,
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      isARepeat: false,
      keyCode: UInt16(kVK_DownArrow),
    ))

    let actual = NSEventValue(nsEvent: event)
    let expected = NSEventValue.key(
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(kVK_DownArrow),
      specialKey: .downArrow,
    )

    #expect(actual == expected)
  }

  @Test
  func `init nsEvent with keyUp event should create key payload`() throws {
    let event = try #require(NSEvent.keyEvent(
      with: .keyUp,
      location: .zero,
      modifierFlags: .command,
      timestamp: .zero,
      windowNumber: .zero,
      context: nil,
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      isARepeat: false,
      keyCode: UInt16(kVK_DownArrow),
    ))

    let actual = NSEventValue(nsEvent: event)
    let expected = NSEventValue.key(
      type: .keyUp,
      modifierFlags: .command,
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(kVK_DownArrow),
      specialKey: .downArrow,
    )

    #expect(actual == expected)
  }

  @Test
  func `init nsEvent with keyDown event should only read key-specific properties`() {
    let event = AccessTrackingEvent()
    event._type = .keyDown
    event._modifierFlags = .command
    event._characters = NSEvent.SpecialKey.downArrow.character
    event._charactersIgnoringModifiers = NSEvent.SpecialKey.downArrow.character
    event._isARepeat = false
    event._keyCode = UInt16(kVK_DownArrow)

    let actual = NSEventValue(nsEvent: event)
    let expected = NSEventValue.key(
      modifierFlags: .command,
      characters: NSEvent.SpecialKey.downArrow.character,
      charactersIgnoringModifiers: NSEvent.SpecialKey.downArrow.character,
      keyCode: UInt16(kVK_DownArrow),
      specialKey: .downArrow,
    )

    #expect(actual == expected)
    #expect(Set(event.accessedEventSpecificProperties) == [
      "characters",
      "charactersIgnoringModifiers",
      "isARepeat",
      "keyCode",
    ])
  }

  @Test
  func `init nsEvent with scroll wheel event should create scroll payload and only read scroll-specific properties`() {
    let event = AccessTrackingEvent()
    event._type = .scrollWheel
    event._modifierFlags = .command
    event._timestamp = 123
    event._windowNumber = 7
    event._locationInWindow = NSPoint(x: 1, y: 2)
    event._deltaX = 3
    event._deltaY = 4
    event._deltaZ = 5
    event._hasPreciseScrollingDeltas = true
    event._scrollingDeltaX = 6
    event._scrollingDeltaY = 7
    event._phase = .changed
    event._momentumPhase = .began
    event._isDirectionInvertedFromDevice = true

    let actual = NSEventValue(nsEvent: event)
    let expected = NSEventValue.scrollWheel(
      locationInWindow: NSPoint(x: 1, y: 2),
      timestamp: 123,
      windowNumber: 7,
      modifierFlags: .command,
      deltaX: 3,
      deltaY: 4,
      deltaZ: 5,
      hasPreciseScrollingDeltas: true,
      scrollingDeltaX: 6,
      scrollingDeltaY: 7,
      phase: .changed,
      momentumPhase: .began,
      isDirectionInvertedFromDevice: true,
    )

    #expect(actual == expected)
    #expect(Set(event.accessedEventSpecificProperties) == [
      "deltaX",
      "deltaY",
      "deltaZ",
      "hasPreciseScrollingDeltas",
      "isDirectionInvertedFromDevice",
      "momentumPhase",
      "phase",
      "scrollingDeltaX",
      "scrollingDeltaY",
    ])
  }

  @Test
  func `init nsEvent with mouse event should create mouse payload and only read mouse-specific properties`() {
    let event = AccessTrackingEvent()
    event._type = .leftMouseDown
    event._modifierFlags = .shift
    event._timestamp = 456
    event._windowNumber = 9
    event._locationInWindow = NSPoint(x: 8, y: 9)
    event._buttonNumber = 1
    event._clickCount = 2
    event._eventNumber = 3
    event._pressure = 0.5

    let actual = NSEventValue(nsEvent: event)
    let expected = NSEventValue.mouse(
      type: .leftMouseDown,
      locationInWindow: NSPoint(x: 8, y: 9),
      timestamp: 456,
      windowNumber: 9,
      modifierFlags: .shift,
      buttonNumber: 1,
      clickCount: 2,
      eventNumber: 3,
      pressure: 0.5,
    )

    #expect(actual == expected)
    #expect(Set(event.accessedEventSpecificProperties) == [
      "buttonNumber",
      "clickCount",
      "eventNumber",
      "pressure",
    ])
  }

  @Test
  func `init nsEvent with unsupported event should create other payload without touching invalid properties`() {
    let event = AccessTrackingEvent()
    event._type = .flagsChanged
    event._modifierFlags = .command
    event._timestamp = 999
    event._windowNumber = 12
    event._locationInWindow = NSPoint(x: 4, y: 5)
    event._characters = nil
    event._charactersIgnoringModifiers = nil
    event._isARepeat = false
    event._keyCode = 0

    let actual = NSEventValue(nsEvent: event)
    let expected = NSEventValue.other(
      type: .flagsChanged,
      locationInWindow: NSPoint(x: 4, y: 5),
      timestamp: 999,
      windowNumber: 12,
      modifierFlags: .command,
    )

    #expect(actual == expected)
    #expect(event.accessedEventSpecificProperties.isEmpty)
  }

  @Test(arguments: [
    (actual: NSEventValue.upArrow(), specialKey: NSEvent.SpecialKey.upArrow, keyCode: UInt16(kVK_UpArrow), modifierFlags: NSEvent.ModifierFlags()),
    (actual: NSEventValue.rightArrow(), specialKey: NSEvent.SpecialKey.rightArrow, keyCode: UInt16(kVK_RightArrow), modifierFlags: NSEvent.ModifierFlags()),
    (actual: NSEventValue.downArrow(), specialKey: NSEvent.SpecialKey.downArrow, keyCode: UInt16(kVK_DownArrow), modifierFlags: NSEvent.ModifierFlags()),
    (actual: NSEventValue.leftArrow(), specialKey: NSEvent.SpecialKey.leftArrow, keyCode: UInt16(kVK_LeftArrow), modifierFlags: NSEvent.ModifierFlags()),
    (actual: NSEventValue.pageUp(), specialKey: NSEvent.SpecialKey.pageUp, keyCode: UInt16(kVK_PageUp), modifierFlags: .init(rawValue: 0x800100)),
    (actual: NSEventValue.pageDown(), specialKey: NSEvent.SpecialKey.pageDown, keyCode: UInt16(kVK_PageDown), modifierFlags: .init(rawValue: 0x800100)),
    (actual: NSEventValue.home(), specialKey: NSEvent.SpecialKey.home, keyCode: UInt16(kVK_Home), modifierFlags: NSEvent.ModifierFlags()),
    (actual: NSEventValue.end(), specialKey: NSEvent.SpecialKey.end, keyCode: UInt16(kVK_End), modifierFlags: NSEvent.ModifierFlags()),
  ])
  func `convenience key helpers should create expected payloads`(
    actual: NSEventValue,
    specialKey: NSEvent.SpecialKey,
    keyCode: UInt16,
    modifierFlags: NSEvent.ModifierFlags,
  ) {
    let expected = NSEventValue.key(
      modifierFlags: modifierFlags,
      characters: specialKey.character,
      charactersIgnoringModifiers: specialKey.character,
      keyCode: keyCode,
      specialKey: specialKey,
    )

    #expect(actual == expected)
  }
}
