@preconcurrency
import AppKit
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NSEventClient

@DependencyClient
public struct NSEventClient: Sendable {
  // key event information
  public var keyRepeatDelay: @MainActor @Sendable () -> TimeInterval = { .zero }
  public var keyRepeatInterval: @MainActor @Sendable () -> TimeInterval = { .zero }
  //
  public var mouseLocation: @MainActor @Sendable () -> NSPoint = { .zero }
  public var globalEvents: @MainActor @Sendable (_ mask: NSEvent.EventTypeMask) -> AsyncStream<NSEventValue> = {
    _ in .finished
  }

  public var localEvents:
    @MainActor @Sendable (_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent) -> NSEvent?) ->
    AsyncStream<NSEventValue> = { _, _ in .finished }
}

// MARK: DependencyKey

extension NSEventClient: DependencyKey {

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
    localEvents: { mask, handler in
      let (stream, continuation) = AsyncStream.makeStream(of: NSEventValue.self)
      let monitor =
        NSEvent
          .addLocalMonitorForEvents(
            matching: mask,
            handler: { nsEvent in
              continuation.yield(NSEventValue(nsEvent: nsEvent))
              return handler(nsEvent)
            },
          )
      continuation.onTermination = { _ in
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
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
