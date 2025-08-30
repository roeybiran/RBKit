import Carbon

public final class CGEventClientMock: CGEventClientProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public typealias MachPort = MachPortMock

  public var _createEventTap: (
    _ tap: CGEventTapLocation,
    _ place: CGEventTapPlacement,
    _ options: CGEventTapOptions,
    _ eventsOfInterest: CGEventMask,
    _ userInfo: UnsafeMutableRawPointer?
  ) -> MachPortMock? = { _, _, _, _, _ in nil }

  public var _getEnabled: (_ tap: MachPortMock) -> Bool = { _ in false }

  public var _setEnabled: (_ tap: MachPortMock, _ isEnabled: Bool) -> Void = { _, _ in }

  public var _flags: @Sendable (_ event: CGEvent) -> CGEventFlags = { _ in [] }

  public var _getIntegerValue: @Sendable (_ event: CGEvent, _ field: CGEventField) -> Int64 = { _, _ in 0 }

  public func createEventTap(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    userInfo: UnsafeMutableRawPointer?
  ) -> MachPortMock? {
    _createEventTap(tap, place, options, eventsOfInterest, userInfo)
  }

  public func getEnabled(tap: MachPortMock) -> Bool {
    _getEnabled(tap)
  }

  public func setEnabled(tap: MachPortMock, isEnabled: Bool) {
    _setEnabled(tap, isEnabled)
  }

  public func flags(event: CGEvent) -> CGEventFlags {
    _flags(event)
  }

  public func getIntegerValue(event: CGEvent, field: CGEventField) -> Int64 {
    _getIntegerValue(event, field)
  }

}
