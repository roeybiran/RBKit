import Carbon

public struct CFMachPortClientLive: CFMachPortClientProtocol {
  public init() { }

  public typealias MachPort = CFMachPort
  public typealias RunLoopSource = CFRunLoopSource

  public func invalidate(machPort: CFMachPort) {
    CFMachPortInvalidate(machPort)
  }

  public func createRunLoopSource(port: CFMachPort, order: CFIndex) -> CFRunLoopSource {
    CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, order)
  }

}
