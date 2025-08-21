import Dependencies
import DependenciesMacros

public enum AXClientKey: DependencyKey {
  public static let liveValue: any AXClient = AXClientLive()
  public static let testValue: any AXClient = AXClientMock()
}

extension DependencyValues {
  public var axClient: any AXClient {
    get { self[AXClientKey.self] }
    set { self[AXClientKey.self] = newValue }
  }
}
