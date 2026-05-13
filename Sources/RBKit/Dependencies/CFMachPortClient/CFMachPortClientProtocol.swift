import Carbon

public protocol CFMachPortClientProtocol: Sendable {
  associatedtype MachPort: AnyObject
  associatedtype RunLoopSource: AnyObject

  func invalidate(machPort: MachPort)
  func createRunLoopSource(port: MachPort, order: CFIndex) -> RunLoopSource
}
