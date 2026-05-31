@preconcurrency import CoreFoundation

public protocol CFRunLoopClientProtocol: Sendable {
  associatedtype RunLoop: AnyObject & Hashable & Sendable
  associatedtype RunLoopSource: AnyObject & Hashable & Sendable

  func getCurrent() -> RunLoop?
  func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode)
  func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode)
}
