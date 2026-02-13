import Carbon

public final class CFMachPortClientMock: CFMachPortClientProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public typealias MachPort = MachPortMock
  public typealias RunLoopSource = RunLoopSourceMock

  public var _invalidate: (_ machPort: MachPortMock) -> Void = { _ in }

  public var _createRunLoopSource: (
    _ port: MachPortMock,
    _ order: CFIndex
  ) -> RunLoopSourceMock = { _, _ in RunLoopSourceMock(id: "mock") }

  public func invalidate(machPort: MachPortMock) {
    _invalidate(machPort)
  }

  public func createRunLoopSource(port: MachPortMock, order: CFIndex) -> RunLoopSourceMock {
    _createRunLoopSource(port, order)
  }

}
