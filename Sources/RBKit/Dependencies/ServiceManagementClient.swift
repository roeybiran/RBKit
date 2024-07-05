import ServiceManagement
import Dependencies
import DependenciesMacros

public enum Status: Int {
  case notRegistered
  case enabled
  case requiresApproval
  case notFound
}

@DependencyClient
public struct ServiceManagementClient {
  public var register: () throws -> Void
  public var unregister: () throws -> Void
  public var status: () -> Status?
}

extension ServiceManagementClient: DependencyKey {
  public static let liveValue: Self = {
    if #available(macOS 13.0, *) {
      let instance = SMAppService.mainApp
      return .init(
        register: { try instance.register() },
        unregister: { try instance.unregister() },
        status: { .init(rawValue: instance.status.rawValue) }
      )
    } else {
      return .init(
        register: { },
        unregister: { },
        status: { .notFound }
      )
    }
  }()

  public static let testValue = Self()
}


extension DependencyValues {
  public var serviceManagementClient: ServiceManagementClient {
    get { self[ServiceManagementClient.self] }
    set { self[ServiceManagementClient.self] = newValue }
  }
}
