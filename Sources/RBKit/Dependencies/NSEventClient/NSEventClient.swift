import AppKit
import Dependencies
import DependenciesMacros

// MARK: - NSEventClient

@DependencyClient
public struct NSEventClient: Sendable {
  // key event information
  public var keyRepeatDelay: @Sendable () -> TimeInterval = { .zero }
  public var keyRepeatInterval: @Sendable () -> TimeInterval = { .zero }
  //
  public var mouseLocation: @Sendable () -> NSPoint = { .zero }
  public var globalEvents: @MainActor @Sendable (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = { _ in .finished }
  public var addLocalMonitor: @Sendable (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) -> Any? = { _, _ in nil }
  public var removeMonitor: @Sendable (_ monitor: Any) -> Void
  ///
  public var specialKey: @Sendable (_ event: NSEvent) -> NSEvent.SpecialKey?
}

// MARK: DependencyKey

extension NSEventClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    keyRepeatDelay: { NSEvent.keyRepeatDelay },
    keyRepeatInterval: { NSEvent.keyRepeatInterval },
    mouseLocation: { NSEvent.mouseLocation },
    globalEvents: { mask in
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
    addLocalMonitor: { NSEvent.addLocalMonitorForEvents(matching: $0, handler: $1) },
    removeMonitor: { NSEvent.removeMonitor($0) },
    specialKey: { $0.specialKey })

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsEventClient: NSEventClient {
    get { self[NSEventClient.self] }
    set { self[NSEventClient.self] = newValue }
  }
}
