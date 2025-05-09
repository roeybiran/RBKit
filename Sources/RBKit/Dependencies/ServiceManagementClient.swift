import Dependencies
import DependenciesMacros
import ServiceManagement

// MARK: - Status

public enum Status: Int {
  case notRegistered
  case enabled
  case requiresApproval
  case notFound
}

// MARK: - ServiceManagementClient

@DependencyClient
public struct ServiceManagementClient: Sendable {
  public var register: @Sendable () throws -> Void
  public var unregister: @Sendable () throws -> Void
  public var status: @Sendable () -> Status?
}

// MARK: DependencyKey

extension ServiceManagementClient: DependencyKey {
  public static let liveValue: Self = {
    .init(
      register: { try SMAppService.mainApp.register() },
      unregister: { try SMAppService.mainApp.unregister() },
      status: { .init(rawValue: SMAppService.mainApp.status.rawValue) })
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var serviceManagementClient: ServiceManagementClient {
    get { self[ServiceManagementClient.self] }
    set { self[ServiceManagementClient.self] = newValue }
  }
}
