import CoreFoundation

public final class CFRunLoopClientMock: CFRunLoopClientProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public typealias RunLoop = CFRunLoop
  public typealias RunLoopSource = RunLoopSourceMock

  public nonisolated(unsafe) var _getCurrent: () -> RunLoop? = { CFRunLoopGetCurrent() }
  public nonisolated(unsafe) var _addSource: (RunLoop, RunLoopSource, CFRunLoopMode) -> Void = { _, _, _ in }
  public nonisolated(unsafe) var _removeSource: (RunLoop, RunLoopSource, CFRunLoopMode) -> Void = { _, _, _ in }

  public func getCurrent() -> RunLoop? {
    _getCurrent()
  }

  public func addSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
    _addSource(runLoop, source, mode)
  }

  public func removeSource(runLoop: RunLoop, source: RunLoopSource, mode: CFRunLoopMode) {
    _removeSource(runLoop, source, mode)
  }

}
