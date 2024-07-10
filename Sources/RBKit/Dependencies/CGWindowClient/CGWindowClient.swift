import Dependencies
import DependenciesMacros
import Quartz

// MARK: - CGWindowClient

@DependencyClient
public struct CGWindowClient {
  public var list: (
    _ options: CGWindowListOption /* [.excludeDesktopElements, .optionOnScreenOnly] */,
    _ referenceWindow: CGWindowID /* kCGNullWindowID */ ) -> [CGWindowValue] = { _, _ in [] }
  // https://github.com/nonstrict-hq/ScreenCaptureKit-Recording-example/blob/main/Sources/sckrecording/main.swift
  public var checkCaptureAccess: () -> Bool = { false }
  public var requestCaptureAccess: () -> Bool = { false }

}

// MARK: DependencyKey

extension CGWindowClient: DependencyKey {
  public static let liveValue = Self(
    list: { options, referenceWindow in
      (CGWindowListCopyWindowInfo(options, referenceWindow) as? [[CFString: Any]])?.compactMap(CGWindowValue.init) ?? []
    },
    checkCaptureAccess: CGPreflightScreenCaptureAccess,
    requestCaptureAccess: CGRequestScreenCaptureAccess)

  public static let testValue = Self()
}

extension DependencyValues {
  public var cgWindowClient: CGWindowClient {
    get { self[CGWindowClient.self] }
    set { self[CGWindowClient.self] = newValue }
  }
}
