import Dependencies

// MARK: - CGEventClientKey

public enum CGEventClientKey: DependencyKey {
  public static let liveValue: any CGEventClientProtocol = CGEventClientLive()
  public static let testValue: any CGEventClientProtocol = CGEventClientMock()
}

extension DependencyValues {
  public var cgEventClient: any CGEventClientProtocol {
    get { self[CGEventClientKey.self] }
    set { self[CGEventClientKey.self] = newValue }
  }
}
