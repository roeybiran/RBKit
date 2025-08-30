import Carbon

public protocol CGEventClientProtocol {
  associatedtype MachPort: AnyObject

  func createEventTap(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    userInfo: UnsafeMutableRawPointer?
  ) -> MachPort?

  func getEnabled(tap: MachPort) -> Bool
  func setEnabled(tap: MachPort, isEnabled: Bool)
  func flags(event: CGEvent) -> CGEventFlags
  func getIntegerValue(event: CGEvent, field: CGEventField) -> Int64
}
