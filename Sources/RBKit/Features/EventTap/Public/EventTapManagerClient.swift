import Carbon
import Dependencies
import DependenciesMacros

// MARK: - EventTapManagerClient

@DependencyClient
public struct EventTapManagerClient: Sendable {
  public typealias ID = String
  public typealias Callback = (_ type: CGEventType, _ event: CGEvent) -> CGEvent?

  public var start: @Sendable @MainActor (
    _ id: ID,
    _ events: [CGEventType],
    _ place: CGEventTapPlacement,
    _ callback: @escaping Callback,
  ) -> Void
  public var stop: @Sendable @MainActor (_ id: ID) -> Void
  public var getIsEnabled: @Sendable @MainActor (_ id: ID) -> Bool = { _ in false }
  public var setIsEnabled: @Sendable @MainActor (_ id: ID, _ enabled: Bool) -> Void
}

// MARK: DependencyKey

extension EventTapManagerClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    start: { manager.start(id: $0, eventsOfInterest: $1, place: $2, clientCallback: $3) },
    stop: { manager.stop(id: $0) },
    getIsEnabled: { manager.getIsEnabled(id: $0) },
    setIsEnabled: { manager.setIsEnabled(id: $0, $1) },
  )
  public static let testValue = Self()

  // MARK: Internal

  @MainActor static let manager = EventTapManager(
    cgEventClient: CGEventClientLive(),
    cfMachPortClient: CFMachPortClientLive(),
    cfRunLoopClient: CFRunLoopClientLive(),
  )

}

extension DependencyValues {
  public var eventTapClient: EventTapManagerClient {
    get { self[EventTapManagerClient.self] }
    set { self[EventTapManagerClient.self] = newValue }
  }
}
