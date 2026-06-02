import Carbon
import Dependencies
import DependenciesMacros

// MARK: - EventTapManagerClient

@DependencyClient
public struct EventTapManagerClient: Sendable {
  public typealias ID = String
  public typealias Callback = (_ type: CGEventType, _ event: CGEvent) -> CGEvent?

  public var add: @Sendable (
    _ id: ID,
    _ events: [CGEventType],
    _ place: CGEventTapPlacement,
    _ callback: @escaping Callback,
  ) async -> Void
  public var remove: @Sendable (_ id: ID) async -> Void
  public var setIsEnabled: @Sendable (_ id: ID, _ enabled: Bool) async -> Void
}

// MARK: DependencyKey

extension EventTapManagerClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    add: { await manager.add(id: $0, eventsOfInterest: $1, place: $2, clientCallback: $3) },
    remove: { await manager.remove(id: $0) },
    setIsEnabled: { await manager.setIsEnabled(id: $0, $1) },
  )
  public static let testValue = Self()

  // MARK: Internal

  static let manager = EventTapManager(
    cgEventClient: CGEventClientLive(),
    cfMachPortClient: CFMachPortClientLive(),
    cfRunLoopClient: CFRunLoopClientLive.Main(),
  )

}

extension DependencyValues {
  public var eventTapManagerClient: EventTapManagerClient {
    get { self[EventTapManagerClient.self] }
    set { self[EventTapManagerClient.self] = newValue }
  }
}
