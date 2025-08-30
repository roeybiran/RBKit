import Dependencies

// MARK: - CFMachPortClientKey

public enum CFMachPortClientKey: DependencyKey {
  public static let liveValue: any CFMachPortClient = CFMachPortClientLive()
  public static let testValue: any CFMachPortClient = CFMachPortClientMock()
}

extension DependencyValues {
  public var cfMachPortClient: any CFMachPortClient {
    get { self[CFMachPortClientKey.self] }
    set { self[CFMachPortClientKey.self] = newValue }
  }
}
