import Dependencies
import DependenciesMacros
import Foundation

// MARK: - UserScriptTaskClient

@DependencyClient
public struct UserScriptTaskClient: Sendable {
  public var create: @Sendable (_ url: URL) throws -> NSUserScriptTask
  public var execute: @Sendable (_ task: NSUserScriptTask) async throws -> Void
}

// MARK: DependencyKey

extension UserScriptTaskClient: DependencyKey {
  public static let liveValue = Self(
    create: { try NSUserScriptTask(url: $0) },
    execute: { try await $0.execute() })

  public static let testValue = Self()
}

extension DependencyValues {
  public var userScriptTaskClient: UserScriptTaskClient {
    get { self[UserScriptTaskClient.self] }
    set { self[UserScriptTaskClient.self] = newValue }
  }
}
