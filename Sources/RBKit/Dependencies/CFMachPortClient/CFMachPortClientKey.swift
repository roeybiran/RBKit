import Dependencies

// MARK: - CFMachPortClientKey

public enum CFMachPortClientKey: DependencyKey {
  public static let liveValue: any CFMachPortClientProtocol = CFMachPortClientLive()
  public static let testValue: any CFMachPortClientProtocol = CFMachPortClientMock()
}

extension DependencyValues {
  public var cfMachPortClient: any CFMachPortClientProtocol {
    get { self[CFMachPortClientKey.self] }
    set { self[CFMachPortClientKey.self] = newValue }
  }
}
