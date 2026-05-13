import Carbon

public protocol CFRunLoopClientProtocol: Sendable {
  associatedtype RunLoopSource: AnyObject

  func add(source: RunLoopSource, to runLoop: CFRunLoop, mode: CFRunLoopMode)
  func remove(source: RunLoopSource, from runLoop: CFRunLoop, mode: CFRunLoopMode)
}
