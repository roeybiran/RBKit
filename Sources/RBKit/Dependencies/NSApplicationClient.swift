import AppKit.NSApplication
import Dependencies

// MARK: - NSApplicationClient

public struct NSApplicationClient {
  public var terminate: (_ sender: Any?) -> Void
}

// MARK: DependencyKey

extension NSApplicationClient: DependencyKey {
  public static let liveValue = NSApplicationClient(terminate: { sender in NSApplication.shared.terminate(sender) })
  public static let testValue = NSApplicationClient(terminate: unimplemented("NSAppClient.terminate"))
}

extension DependencyValues {
  public var nsApplicationClient: NSApplicationClient {
    get { self[NSApplicationClient.self] }
    set { self[NSApplicationClient.self] = newValue }
  }
}
