import Dependencies

// MARK: - CFRunLoopClientKey

public enum CFRunLoopClientKey: DependencyKey {
  public static let liveValue: any CFRunLoopClientProtocol = CFRunLoopClientLive.Main()
  public static let testValue: any CFRunLoopClientProtocol = CFRunLoopClientMock()
}

extension DependencyValues {
  public var cfRunLoopClient: any CFRunLoopClientProtocol {
    get { self[CFRunLoopClientKey.self] }
    set { self[CFRunLoopClientKey.self] = newValue }
  }
}
