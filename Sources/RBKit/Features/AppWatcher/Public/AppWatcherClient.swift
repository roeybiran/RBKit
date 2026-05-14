import AppKit
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - AppWatcherClient

@DependencyClient
public struct AppWatcherClient: Sendable {
  public var events: @MainActor @Sendable () -> AsyncStream<AppWatcherEvent> = { .init { $0.finish() } }
}

// MARK: DependencyKey

extension AppWatcherClient: DependencyKey {
  public static let liveValue = Self(events: {
    withDependencies { deps in
      deps.nsWorkspaceClient = .liveValue
      deps.nsRunningApplicationClient = .liveValue
    } operation: {
      AppWatcher().events()
    }
  })

  public static let testValue = Self()
}

extension DependencyValues {
  public var appWatcherClient: AppWatcherClient {
    get { self[AppWatcherClient.self] }
    set { self[AppWatcherClient.self] = newValue }
  }
}
