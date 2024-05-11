import AppKit
import Dependencies
import DependenciesMacros

// MARK: - EventMonitor

@DependencyClient
public struct NSEventClient {
  public var mouseLocation: () -> NSPoint = { .zero }
  public var globalEvents: (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = { _ in .finished }
  public var localEvents: (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) -> AsyncStream<NSEvent> = { _, _ in .finished }
}

extension NSEventClient: DependencyKey {
  // MARK: Public

  public static let liveValue = Self(
    mouseLocation: { NSEvent.mouseLocation },
    globalEvents: { mask in
      AsyncStream { continuation in
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

      }
    },
    localEvents: { mask, handler in
      AsyncStream { continuation in
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
      }
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
