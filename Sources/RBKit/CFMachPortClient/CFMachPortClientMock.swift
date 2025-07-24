import Carbon

public final class CFMachPortClientMock: CFMachPortClient {
  public var _invalidate: (_ machPort: MachPortMock) -> Void = { _ in }

  public func invalidate(machPort: MachPortMock) {
    _invalidate(machPort)
  }

  public var _createRunLoopSource: (
    _ port: MachPortMock,
    _ order: CFIndex
  ) -> RunLoopSourceMock = { _, _ in RunLoopSourceMock(id: "mock") }

  public func createRunLoopSource(port: MachPortMock, order: CFIndex) -> RunLoopSourceMock {
    return _createRunLoopSource(port, order)
  }

  public typealias MachPort = MachPortMock
  public typealias RunLoopSource = RunLoopSourceMock
}
