import AppKit
import Dependencies
import DependenciesMacros

// MARK: - EventMonitor

@DependencyClient
public struct NSEventClient {
  public var mouseLocation: () -> NSPoint = { .zero }
  public var globalEvents: (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = { _ in .finished }
  public var addLocalMonitor: (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) -> Void
  public var stopLocalMonitor: () -> Void
}

extension NSEventClient: DependencyKey {
  // MARK: Public
  private static var monitor: Any?
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
    addLocalMonitor: { mask, handler in
      guard monitor == nil else { return }
      monitor = NSEvent
        .addLocalMonitorForEvents(
          matching: mask,
          handler: handler
        )
    },
    stopLocalMonitor: {
      guard let monitor else { return }
      NSEvent.removeMonitor(monitor as Any)
      Self.monitor = nil
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
