import Carbon

public final class CGEventClientMock: CGEventClientProtocol {
  public var _createEventTap: (
    _ tap: CGEventTapLocation,
    _ place: CGEventTapPlacement,
    _ options: CGEventTapOptions,
    _ eventsOfInterest: CGEventMask,
    _ userInfo: UnsafeMutableRawPointer?
  ) -> MachPortMock? = { _, _, _, _, _ in nil }

  public func createEventTap(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    userInfo: UnsafeMutableRawPointer?
  ) -> MachPortMock? {
    return _createEventTap(tap, place, options, eventsOfInterest, userInfo)
  }

  public var _getEnabled: (_ tap: MachPortMock) -> Bool = { _ in false }

  public func getEnabled(tap: MachPortMock) -> Bool {
    return _getEnabled(tap)
  }

  public var _setEnabled: (_ tap: MachPortMock, _ isEnabled: Bool) -> Void = { _, _ in }

  public func setEnabled(tap: MachPortMock, isEnabled: Bool) {
    _setEnabled(tap, isEnabled)
  }

  public var _flags: @Sendable (_ event: CGEvent) -> CGEventFlags = { _ in [] }

  public func flags(event: CGEvent) -> CGEventFlags {
    return _flags(event)
  }

  public var _getIntegerValue: @Sendable (_ event: CGEvent, _ field: CGEventField) -> Int64 = { _, _ in 0 }

  public func getIntegerValue(event: CGEvent, field: CGEventField) -> Int64 {
    return _getIntegerValue(event, field)
  }

  public typealias MachPort = MachPortMock
}
