import Dependencies
import DependenciesMacros

// MARK: - AXClientKey

public enum AXClientKey: DependencyKey {
  public static let liveValue: any AXClientProtocol = AXClientLive()
  public static let testValue: any AXClientProtocol = AXClientMock()
}

extension DependencyValues {
  public var axClient: any AXClientProtocol {
    get { self[AXClientKey.self] }
    set { self[AXClientKey.self] = newValue }
  }
}
