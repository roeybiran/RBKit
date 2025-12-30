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
    _ callback: @escaping Callback
  )
    -> Void
  public var stop: @Sendable @MainActor (_ id: ID) -> Void
  public var getIsEnabled: @Sendable @MainActor (_ id: ID) -> Bool = { _ in false }
  public var setIsEnabled: @Sendable @MainActor (_ id: ID, _ enabled: Bool) -> Void
}

// MARK: DependencyKey

extension EventTapManagerClient: DependencyKey {
  public static let liveValue: Self = {
    let instance = EventTapManager(
      cgEventClient: CGEventClientLive(),
      cfMachPortClient: CFMachPortClientLive(),
      cfRunLoopClient: CFRunLoopClientLive()
    )
    return Self(
      start: { instance.start(id: $0, eventsOfInterest: $1, place: $2, clientCallback: $3) },
      stop: { instance.stop(id: $0) },
      getIsEnabled: { instance.getIsEnabled(id: $0) },
      setIsEnabled: { instance.setIsEnabled(id: $0, $1) }
    )
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var eventTapClient: EventTapManagerClient {
    get { self[EventTapManagerClient.self] }
    set { self[EventTapManagerClient.self] = newValue }
  }
}
