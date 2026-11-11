import Dependencies
import DependenciesMacros
import Foundation

// MARK: - SparkleManagerClient

@DependencyClient
struct SparkleManagerClient: Sendable {
  var start: @MainActor @Sendable () -> AsyncStream<SparkleManager.State> = { .finished }
  var checkForUpdates: @MainActor @Sendable () -> Void
  var getAutomaticallyChecksForUpdates: @MainActor @Sendable () -> Bool = { false }
  var setAutomaticallyChecksForUpdates: @MainActor @Sendable (Bool) -> Void
  var getAutomaticallyDownloadsUpdates: @MainActor @Sendable () -> Bool = { false }
  var setAutomaticallyDownloadsUpdates: @MainActor @Sendable (Bool) -> Void
  var getLastUpdateCheckDate: @MainActor @Sendable () -> Date?
}

// MARK: DependencyKey

extension SparkleManagerClient: DependencyKey {

  // MARK: Internal

  static let liveValue = Self(
    start: { manager.start() },
    checkForUpdates: { manager.checkForUpdates() },
    getAutomaticallyChecksForUpdates: { manager.getAutomaticallyChecksForUpdates() },
    setAutomaticallyChecksForUpdates: { manager.setAutomaticallyChecksForUpdates($0) },
    getAutomaticallyDownloadsUpdates: { manager.getAutomaticallyDownloadsUpdates() },
    setAutomaticallyDownloadsUpdates: { manager.setAutomaticallyDownloadsUpdates($0) },
    getLastUpdateCheckDate: { manager.getLastUpdateCheckDate() },
  )

  static let testValue = Self()

  // MARK: Private

  @MainActor private static let manager = SparkleManager()
}

extension DependencyValues {
  var sparkleManagerClient: SparkleManagerClient {
    get { self[SparkleManagerClient.self] }
    set { self[SparkleManagerClient.self] = newValue }
  }
}
