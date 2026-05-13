import Carbon
import Dependencies
import DependenciesMacros

// MARK: - CarbonEventsCoreClient

@DependencyClient
public struct CarbonEventsCoreClient: Sendable {
  public var installEventHandler: @Sendable (
    _ target: EventTargetRef,
    _ numEventTypes: Int,
    _ eventTypes: [EventTypeSpec],
    _ box: BoxedHotKeyHandler,
  ) -> (
    EventHandlerRef?,
    OSStatus,
  ) = { _, _, _, _ in (nil, 0) }
  public var removeEventHandler: @Sendable (_ target: EventHandlerRef) -> OSStatus = { _ in 0 }
  public var getEventDispatcherTarget: @Sendable () -> EventTargetRef? = { nil }
  public var registerEventHotKey: @Sendable (
    _ keyCode: UInt32,
    _ modifiers: UInt32,
    _ hotKeyID: EventHotKeyID,
    _ target: EventTargetRef,
    _ options: UInt32,
  ) -> (EventHotKeyRef?, OSStatus) = { _, _, _, _, _ in (nil, 0) }
  public var unregisterEventHotKey: @Sendable (_ event: EventHotKeyRef) -> OSStatus = { _ in 0 }
  public var getEventParameter: @Sendable (
    _ inEvent: EventRef,
    _ inName: EventParamName,
    _ inDesiredType: EventParamType,
    _ outActualType: UnsafeMutablePointer<EventParamType>?,
    _ inBufferSize: Int,
    _ outActualSize: UnsafeMutablePointer<Int>?,
    _ outData: UnsafeMutableRawPointer?,
  ) -> OSStatus = { _, _, _, _, _, _, _ in 0 }
  public var getEventKind: @Sendable (_ eventRef: EventRef) -> UInt32 = { _ in 0 }
}

// MARK: DependencyKey

extension CarbonEventsCoreClient: DependencyKey {
  public static let liveValue = Self(
    installEventHandler: { target, numEventTypes, eventTypes, box in
      var eventHandlerRef: EventHandlerRef?
      let status = InstallEventHandler(
        target,
        { _, event, userData in
          guard let userData else {
            return OSStatus(eventNotHandledErr)
          }

          let boxPointer = UInt(bitPattern: userData)
          let eventPointer = event.map { UInt(bitPattern: $0) }
          return MainActor.assumeIsolated {
            let box = Unmanaged<BoxedHotKeyHandler>
              .fromOpaque(UnsafeRawPointer(bitPattern: boxPointer)!)
              .takeUnretainedValue()
            let event = eventPointer.map { EventRef(bitPattern: $0)! }
            return box.callback(event)
          }
        },
        numEventTypes,
        eventTypes,
        Unmanaged.passUnretained(box).toOpaque(),
        &eventHandlerRef,
      )
      return (eventHandlerRef, status)
    },
    removeEventHandler: { RemoveEventHandler($0) },
    getEventDispatcherTarget: { GetEventDispatcherTarget() },
    registerEventHotKey: { keyCode, modifiers, hotKeyID, target, options in
      var eventHotKeyRef: EventHotKeyRef?
      let status = RegisterEventHotKey(
        keyCode,
        modifiers,
        hotKeyID,
        target,
        options,
        &eventHotKeyRef,
      )
      return (eventHotKeyRef, status)
    },
    unregisterEventHotKey: { UnregisterEventHotKey($0) },
    getEventParameter: { GetEventParameter($0, $1, $2, $3, $4, $5, $6) },
    getEventKind: { GetEventKind($0) },
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var carbonEventsCoreClient: CarbonEventsCoreClient {
    get { self[CarbonEventsCoreClient.self] }
    set { self[CarbonEventsCoreClient.self] = newValue }
  }
}
