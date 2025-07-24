import Carbon

public struct CGEventClientLive: CGEventClientProtocol {
  public func createEventTap(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    userInfo: UnsafeMutableRawPointer?
  ) -> CFMachPort? {
    CGEvent.tapCreate(
      tap: tap,
      place: place,
      options: options,
      eventsOfInterest: eventsOfInterest,
      callback: { proxy, type, event, refcon in
        guard let refcon else { return nil }
        let box = Unmanaged<Box>.fromOpaque(refcon).takeUnretainedValue()
        return box.eventHandler(proxy, type, event)
      },
      userInfo: userInfo
    )
  }

  public func getEnabled(tap: CFMachPort) -> Bool {
    CGEvent.tapIsEnabled(tap: tap)
  }

  public func setEnabled(tap: CFMachPort, isEnabled: Bool) {
    CGEvent.tapEnable(tap: tap, enable: isEnabled)
  }

  public func flags(event: CGEvent) -> CGEventFlags {
    event.flags
  }

  public func getIntegerValue(event: CGEvent, field: CGEventField) -> Int64 {
    event.getIntegerValueField(field)
  }

  public typealias MachPort = CFMachPort
}
