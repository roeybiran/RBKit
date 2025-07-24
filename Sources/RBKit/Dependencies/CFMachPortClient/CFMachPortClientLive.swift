import Carbon

public struct CFMachPortClientLive: CFMachPortClient {
  public init() {}
  
  public func invalidate(machPort: CFMachPort) {
    CFMachPortInvalidate(machPort)
  }

  public func createRunLoopSource(port: CFMachPort, order: CFIndex) -> CFRunLoopSource {
    CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, order)
  }

  public typealias MachPort = CFMachPort
  public typealias RunLoopSource = CFRunLoopSource
}
