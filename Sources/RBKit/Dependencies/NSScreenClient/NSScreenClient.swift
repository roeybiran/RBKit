import AppKit.NSApplication
import AppKit.NSScreen
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - NSScreenClient

@DependencyClient
public struct NSScreenClient: Sendable {
  // alt-tab's handling of `NSScreen.main`: https://github.com/lwouis/alt-tab-macos/blob/8152c3cebf0091385d8ec8d54aeefd805477d864/src/logic/NSScreen.swift#L28
  // see also -- NSScreen.main is not really the active screen: https://stackoverflow.com/a/56268826
  public var main: @Sendable () -> Screen?
  public var deepest: @Sendable () -> Screen?
  public var screens: @Sendable () -> AsyncStream<[Screen]> = { .finished }
}

// MARK: DependencyKey

extension NSScreenClient: DependencyKey {
  public static let liveValue = NSScreenClient(
    main: { NSScreen.main.map(Screen.init) },
    deepest: { NSScreen.deepest.map(Screen.init) },
    screens: {
      @Dependency(\.notificationCenter) var notificationCenter
      let (stream, continuation) = AsyncStream.makeStream(of: [Screen].self)
      let screenParametersTask = Task {
        let notification = NSApplication.didChangeScreenParametersNotification
        for await _ in notificationCenter.notifications(named: notification) {
          continuation.yield(NSScreen.screens.map(Screen.init))
        }
      }

      continuation.onTermination = { _ in
        screenParametersTask.cancel()
      }

      continuation.yield(NSScreen.screens.map(Screen.init))
      return stream
    },
  )

  public static let testValue = NSScreenClient()
}

extension DependencyValues {
  public var screenClient: NSScreenClient {
    get { self[NSScreenClient.self] }
    set { self[NSScreenClient.self] = newValue }
  }
}
