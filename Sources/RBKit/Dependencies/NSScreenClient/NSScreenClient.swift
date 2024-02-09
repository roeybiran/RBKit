import AppKit.NSScreen
import Dependencies
import DependenciesMacros

// MARK: - NSScreenClient

@DependencyClient
public struct NSScreenClient {
  public var main: () -> NSScreenValue?
  public var deepest: () -> NSScreenValue?
  public var screens: () -> [NSScreenValue] = { [] }

  public static let liveValue = NSScreenClient(
    main: { NSScreen.main.map(NSScreenValue.init) },
    deepest: { NSScreen.deepest.map(NSScreenValue.init) },
    screens: { NSScreen.screens.map(NSScreenValue.init) })

  public static let testValue = NSScreenClient()
}

// MARK: DependencyKey

// NotificationCenter
//   .default
//   .publisher(for: NSApplication.didChangeScreenParametersNotification)
//   .sink { [weak self] _ in
//     guard let self else { return }
// self.viewStore?.send(.didBecomeKey(screen: self.window?.screen.map(Screen.init)))
//   }
//   .store(in: &cancellables)

extension NSScreenClient: DependencyKey { }

extension DependencyValues {
  public var screenClient: NSScreenClient {
    get { self[NSScreenClient.self] }
    set { self[NSScreenClient.self] = newValue }
  }
}
