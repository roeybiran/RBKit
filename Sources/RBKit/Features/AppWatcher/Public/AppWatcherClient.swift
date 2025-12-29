import AppKit
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - AppWatcherClient

@DependencyClient
public struct AppWatcherClient: Sendable {
  public var events: @MainActor @Sendable () -> AsyncStream<AppWatcherEvent> = { .finished }
}

// MARK: DependencyKey

extension AppWatcherClient: DependencyKey {
  public static let liveValue = Self(events: {
    let instance = AppWatcher(workspace: .shared)
    let (stream, cont) = AsyncStream.makeStream(of: AppWatcherEvent.self)
    let task = Task {
      for await event in instance.events() {
        cont.yield(event)
      }
    }
    cont.onTermination = { _ in
      task.cancel()
    }
    return stream
  })

  public static let testValue = Self()
}

extension DependencyValues {
  public var appWatcherClient: AppWatcherClient {
    get { self[AppWatcherClient.self] }
    set { self[AppWatcherClient.self] = newValue }
  }
}
