import Carbon
import os

public final class CFRunLoopClientMock: CFRunLoopClientProtocol {

  // MARK: Lifecycle

  public nonisolated init() { }

  // MARK: Public

  public typealias RunLoopSource = RunLoopSourceMock

  public var _add: @Sendable (
    _ source: RunLoopSourceMock,
    _ runLoop: CFRunLoop,
    _ mode: CFRunLoopMode,
  ) -> Void {
    get { state.withLock { $0.add } }
    set { state.withLock { $0.add = newValue } }
  }

  public var _remove: @Sendable (
    _ source: RunLoopSourceMock,
    _ runLoop: CFRunLoop,
    _ mode: CFRunLoopMode,
  ) -> Void {
    get { state.withLock { $0.remove } }
    set { state.withLock { $0.remove = newValue } }
  }

  public func add(source: RunLoopSourceMock, to runLoop: CFRunLoop, mode: CFRunLoopMode) {
    _add(source, runLoop, mode)
  }

  public func remove(source: RunLoopSourceMock, from runLoop: CFRunLoop, mode: CFRunLoopMode) {
    _remove(source, runLoop, mode)
  }

  // MARK: Private

  private struct State: Sendable {
    var add: @Sendable (
      _ source: RunLoopSourceMock,
      _ runLoop: CFRunLoop,
      _ mode: CFRunLoopMode,
    ) -> Void = { _, _, _ in }
    var remove: @Sendable (
      _ source: RunLoopSourceMock,
      _ runLoop: CFRunLoop,
      _ mode: CFRunLoopMode,
    ) -> Void = { _, _, _ in }
  }

  private let state = OSAllocatedUnfairLock(initialState: State())

}
