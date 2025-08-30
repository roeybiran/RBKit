import Carbon

public final class CFRunLoopClientMock: CFRunLoopClientProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public typealias RunLoopSource = RunLoopSourceMock

  public var _add: (
    _ source: RunLoopSourceMock,
    _ runLoop: CFRunLoop,
    _ mode: CFRunLoopMode
  ) -> Void = { _, _, _ in }

  public var _remove: (
    _ source: RunLoopSourceMock,
    _ runLoop: CFRunLoop,
    _ mode: CFRunLoopMode
  ) -> Void = { _, _, _ in }

  public func add(source: RunLoopSourceMock, to runLoop: CFRunLoop, mode: CFRunLoopMode) {
    _add(source, runLoop, mode)
  }

  public func remove(source: RunLoopSourceMock, from runLoop: CFRunLoop, mode: CFRunLoopMode) {
    _remove(source, runLoop, mode)
  }

}
