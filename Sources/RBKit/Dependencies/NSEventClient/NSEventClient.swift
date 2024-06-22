import AppKit
import Dependencies
import DependenciesMacros

// MARK: - NSEventClient

@DependencyClient
public struct NSEventClient {
  // key event information
  public var keyRepeatDelay: () -> TimeInterval = { .zero }
  public var keyRepeatInterval: () -> TimeInterval = { .zero }
  //
  public typealias LocalEventsStream = AsyncStream<(NSEvent, (_ event: NSEvent?) -> Void)>
  public var mouseLocation: () -> NSPoint = { .zero }
  public var globalMonitorEvents: (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = { _ in .finished }
  public var localMonitorEvents: (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?)
    -> AsyncStream<NSEvent> = { _, _ in .finished }
  public var addLocalMonitor: (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) -> Void
  public var stopLocalMonitor: () -> Void
  //
  public var specialKey: (_ event: NSEvent) -> NSEvent.SpecialKey?
}

// MARK: DependencyKey

extension NSEventClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    keyRepeatDelay: { NSEvent.keyRepeatDelay },
    keyRepeatInterval: { NSEvent.keyRepeatInterval },
    mouseLocation: { NSEvent.mouseLocation },
    globalMonitorEvents: { mask in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEvent.self)
      let monitor = NSEvent
        .addGlobalMonitorForEvents(
          matching: mask,
          handler: { nsEvent in
            continuation.yield(nsEvent)
          })
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
          })
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
          handler: handler)
    },
    stopLocalMonitor: {
      guard let monitor else { return }
      NSEvent.removeMonitor(monitor as Any)
      Self.monitor = nil
    },
    specialKey: { $0.specialKey }
  )

  public static let testValue = Self()

  // MARK: Private

  private static var monitor: Any?
}

extension DependencyValues {
  public var nsEventClient: NSEventClient {
    get { self[NSEventClient.self] }
    set { self[NSEventClient.self] = newValue }
  }
}
