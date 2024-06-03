import AppKit
import Dependencies
import DependenciesMacros

// MARK: - EventMonitor

@DependencyClient
public struct NSEventClient {
  public typealias LocalEventsStream = AsyncStream<(NSEvent, (_ event: NSEvent?) -> Void)>
  public var mouseLocation: () -> NSPoint = { .zero }
  public var globalEvents: (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = { _ in .finished }
  public var localEvents: (_ mask: NSEvent.EventTypeMask) -> LocalEventsStream = { _ in .finished }
}

extension NSEventClient: DependencyKey {
  // MARK: Public
  public static let liveValue = Self(
    mouseLocation: { NSEvent.mouseLocation },
    globalEvents: { mask in
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
    localEvents: { mask in
      let (stream, continuation) = LocalEventsStream.makeStream()
      let monitor = NSEvent
        .addLocalMonitorForEvents(
          matching: mask,
          handler: { nsEvent in
            var handledEvent: NSEvent?
            continuation.yield((nsEvent, { handledEvent = $0 }))
            return handledEvent
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
