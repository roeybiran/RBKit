import Carbon
import os

public final class CFMachPortClientMock: CFMachPortClientProtocol {

  // MARK: Lifecycle

  public nonisolated init() { }

  // MARK: Public

  public typealias MachPort = MachPortMock
  public typealias RunLoopSource = RunLoopSourceMock

  public var _invalidate: @Sendable (_ machPort: MachPortMock) -> Void {
    get { state.withLock { $0.invalidate } }
    set { state.withLock { $0.invalidate = newValue } }
  }

  public var _createRunLoopSource: @Sendable (
    _ port: MachPortMock,
    _ order: CFIndex,
  ) -> RunLoopSourceMock {
    get { state.withLock { $0.createRunLoopSource } }
    set { state.withLock { $0.createRunLoopSource = newValue } }
  }

  public func invalidate(machPort: MachPortMock) {
    _invalidate(machPort)
  }

  public func createRunLoopSource(port: MachPortMock, order: CFIndex) -> RunLoopSourceMock {
    _createRunLoopSource(port, order)
  }

  // MARK: Private

  private struct State: Sendable {
    var invalidate: @Sendable (_ machPort: MachPortMock) -> Void = { _ in }
    var createRunLoopSource: @Sendable (
      _ port: MachPortMock,
      _ order: CFIndex,
    ) -> RunLoopSourceMock = { _, _ in RunLoopSourceMock(id: "mock") }
  }

  private let state = OSAllocatedUnfairLock(initialState: State())

}
