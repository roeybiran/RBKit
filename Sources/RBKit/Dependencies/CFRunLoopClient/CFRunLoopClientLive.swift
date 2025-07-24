import Carbon

public struct CFRunLoopClientLive: CFRunLoopClientProtocol {
  public init() {}
  
  public func add(source: CFRunLoopSource, to runLoop: CFRunLoop, mode: CFRunLoopMode) {
    CFRunLoopAddSource(runLoop, source, mode)
  }

  public func remove(source: CFRunLoopSource, from runLoop: CFRunLoop, mode: CFRunLoopMode) {
    CFRunLoopRemoveSource(runLoop, source, mode)
  }

  public typealias RunLoopSource = CFRunLoopSource
}
