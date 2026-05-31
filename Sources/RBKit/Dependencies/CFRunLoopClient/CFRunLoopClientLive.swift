@preconcurrency import CoreFoundation

public struct CFRunLoopClientLive: CFRunLoopClientProtocol {
  public init() { }

  public typealias RunLoop = CFRunLoop
  public typealias RunLoopSource = CFRunLoopSource

  public func getCurrent() -> RunLoop? {
    CFRunLoopGetCurrent()
  }

  public func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
    CFRunLoopAddSource(runLoop, source, mode)
  }

  public func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
    CFRunLoopRemoveSource(runLoop, source, mode)
  }

}
