@preconcurrency
import AppKit
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NSEventClient

@DependencyClient
public struct NSEventClient: Sendable {
  public var keyRepeatDelay: @MainActor @Sendable () -> TimeInterval = { .zero }
  public var keyRepeatInterval: @MainActor @Sendable () -> TimeInterval = { .zero }
  public var mouseLocation: @MainActor @Sendable () -> NSPoint = { .zero }
  public var globalEvents: @MainActor @Sendable (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEventValue> = {
    _ in .init { $0.finish() }
  }

  public var addLocalMonitor:
    @MainActor @Sendable (
      _ mask: NSEvent.EventTypeMask,
      _ handler: @escaping @MainActor @Sendable (NSEvent) -> NSEvent?,
    ) -> EventMonitorID = { _, _ in .init() }
  public var removeMonitor:
    @MainActor @Sendable (_ id: EventMonitorID) -> Void = { _ in }
}

// MARK: DependencyKey

extension NSEventClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    keyRepeatDelay: { NSEvent.keyRepeatDelay },
    keyRepeatInterval: { NSEvent.keyRepeatInterval },
    mouseLocation: { NSEvent.mouseLocation },
    globalEvents: { mask in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEventValue.self)
      let monitor =
        NSEvent
          .addGlobalMonitorForEvents(
            matching: mask,
            handler: { nsEvent in
              continuation.yield(NSEventValue(nsEvent: nsEvent))
            },
          )
      continuation.onTermination = { _ in
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
      }
      return stream
    },
    addLocalMonitor: { mask, handler in
      let id = EventMonitorID()
      let monitor = NSEvent.addLocalMonitorForEvents(matching: mask) { event in
        handler(event)
      }
      monitors[id] = monitor
      return id
    },
    removeMonitor: { id in
      guard let monitor = monitors.removeValue(forKey: id) else {
        assertionFailure("Attempted to remove nonexistent NSEvent monitor: \(id)")
        return
      }
      NSEvent.removeMonitor(monitor)
    },
  )

  public static let testValue = Self()

  // MARK: Private

  @MainActor private static var monitors = [UUID: Any]()

}

extension DependencyValues {
  public var nsEventClient: NSEventClient {
    get { self[NSEventClient.self] }
    set { self[NSEventClient.self] = newValue }
  }
}
