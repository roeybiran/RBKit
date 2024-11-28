import AppKit.NSScreen
import Dependencies
import DependenciesMacros

// MARK: - NSScreenClient

@DependencyClient
public struct NSScreenClient: Sendable {
  // alt-tab's handling of `NSScreen.main`: https://github.com/lwouis/alt-tab-macos/blob/8152c3cebf0091385d8ec8d54aeefd805477d864/src/logic/NSScreen.swift#L28
  // see also -- NSScreen.main is not really the active screen: https://stackoverflow.com/a/56268826
  public var main: @Sendable () -> NSScreenValue?
  public var deepest: @Sendable () -> NSScreenValue?
  public var screens: @Sendable () -> [NSScreenValue] = { [] }

  public static let liveValue = NSScreenClient(
    main: { NSScreen.main.map(NSScreenValue.init) },
    deepest: { NSScreen.deepest.map(NSScreenValue.init) },
    screens: { NSScreen.screens.map(NSScreenValue.init) })

  public static let testValue = NSScreenClient()
}

// MARK: DependencyKey

extension NSScreenClient: DependencyKey {}

extension DependencyValues {
  public var screenClient: NSScreenClient {
    get { self[NSScreenClient.self] }
    set { self[NSScreenClient.self] = newValue }
  }
}
