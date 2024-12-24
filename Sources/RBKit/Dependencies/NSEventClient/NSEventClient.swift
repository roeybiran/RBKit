import AppKit
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NSEventClient

@DependencyClient
public struct NSEventClient: Sendable {
  // key event information
  public var keyRepeatDelay: @Sendable () -> TimeInterval = { .zero }
  public var keyRepeatInterval: @Sendable () -> TimeInterval = { .zero }
  //
  public var mouseLocation: @Sendable () -> NSPoint = { .zero }
  public var globalEvents: @Sendable (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEvent> = {
    _ in .finished
  }

  public var localEvents:
    @Sendable (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) ->
    AsyncStream<NSEvent> = { _, _ in .finished }
  ///
  public var specialKey: @Sendable (_ event: NSEvent) -> NSEvent.SpecialKey?
}

// MARK: DependencyKey

extension NSEventClient: DependencyKey {

  public static let liveValue = Self(
    keyRepeatDelay: { NSEvent.keyRepeatDelay },
    keyRepeatInterval: { NSEvent.keyRepeatInterval },
    mouseLocation: { NSEvent.mouseLocation },
    globalEvents: { mask in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEvent.self)
      let monitor =
        NSEvent
          .addGlobalMonitorForEvents(
            matching: mask,
            handler: { nsEvent in
              continuation.yield(nsEvent)
            })
      continuation.onTermination = { _ in
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
      }
      return stream
    },
    localEvents: { mask, handler in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEvent.self)
      let monitor =
        NSEvent
          .addLocalMonitorForEvents(
            matching: mask,
            handler: { nsEvent in
              continuation.yield(nsEvent)
              return handler(nsEvent)
            })
      continuation.onTermination = { _ in
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
      }
      return stream
    },
    specialKey: { $0.specialKey })

  public static let testValue = Self()
}

extension DependencyValues {
  public var nsEventClient: NSEventClient {
    get { self[NSEventClient.self] }
    set { self[NSEventClient.self] = newValue }
  }
}
