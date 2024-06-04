import AppKit
import Dependencies
import DependenciesMacros

// MARK: - EventMonitor

@DependencyClient
public struct NSEventClient {
  public typealias LocalEventsStream = AsyncStream<(NSEvent, (_ event: NSEvent?) -> Void)>
  public var mouseLocation: () -> NSPoint = { .zero }
  public var globalMonitorEvents: (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = { _ in .finished }
  public var localMonitorEvents: (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) -> AsyncStream<NSEvent> = { _, _ in .finished }
}

extension NSEventClient: DependencyKey {
  // MARK: Public
  private static var monitor: Any?
  public static let liveValue = Self(
    mouseLocation: { NSEvent.mouseLocation },
    globalMonitorEvents: { mask in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEvent.self)
      let monitor = NSEvent
        .addGlobalMonitorForEvents(
          matching: mask,
          handler: { nsEvent in
            continuation.yield(nsEvent)
          }
        )
      continuation.onTermination = { _ in
        NSEvent.removeMonitor(monitor as Any)
      }
      return stream
    },
    localMonitorEvents: { mask, handler in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEvent.self)
      let monitor = NSEvent
        .addLocalMonitorForEvents(
          matching: mask,
          handler: { nsEvent in
            continuation.yield(nsEvent)
            return handler(nsEvent)
          }
        )
      continuation.onTermination = { _ in
        NSEvent.removeMonitor(monitor as Any)
      }
      return stream
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsEventClient: NSEventClient {
    get { self[NSEventClient.self] }
    set { self[NSEventClient.self] = newValue }
  }
}
