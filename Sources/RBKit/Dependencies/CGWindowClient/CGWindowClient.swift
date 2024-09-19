import Dependencies
import DependenciesMacros
import Quartz

// MARK: - CGWindowClient

@DependencyClient
public struct CGWindowClient: Sendable {
  public var list: @Sendable (_ options: CGWindowListOption, _ referenceWindow: CGWindowID) -> [CGWindowValue] = { _, _ in [] }
  // https://github.com/nonstrict-hq/ScreenCaptureKit-Recording-example/blob/main/Sources/sckrecording/main.swift
  public var preflightScreenCaptureAccess: @Sendable () -> Bool = { false }
  public var requestScreenCaptureAccess: @Sendable () -> Bool = { false }
}

// MARK: DependencyKey

extension CGWindowClient: DependencyKey {
  public static let liveValue = Self(
    list: { options, referenceWindow in
      // CGWindowListCopyWindowInfo([.excludeDesktopElements, .optionOnScreenOnly], kCGNullWindowID)
      (CGWindowListCopyWindowInfo(options, referenceWindow) as? [[CFString: Any]])?.compactMap(CGWindowValue.init) ?? []
    },
    preflightScreenCaptureAccess: { CGPreflightScreenCaptureAccess() },
    requestScreenCaptureAccess: { CGRequestScreenCaptureAccess() })

  public static let testValue = Self()
}

extension DependencyValues {
  public var cgWindowClient: CGWindowClient {
    get { self[CGWindowClient.self] }
    set { self[CGWindowClient.self] = newValue }
  }
}
