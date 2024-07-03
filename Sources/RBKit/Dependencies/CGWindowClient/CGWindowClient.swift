import Quartz
import Dependencies
import DependenciesMacros

@DependencyClient
public struct CGWindowClient {
  public var list: (_ options: CGWindowListOption /*[.excludeDesktopElements, .optionOnScreenOnly]*/, _ referenceWindow: CGWindowID /*kCGNullWindowID*/) -> [CGWindowValue] = { _, _ in [] }
  public var checkCaptureAccess: () -> Bool = { false }
  public var requestCaptureAccess: () -> Bool = { false }

}

extension CGWindowClient: DependencyKey {
  public static let liveValue: Self = {
    Self(
      list: { options, referenceWindow in
        (CGWindowListCopyWindowInfo(options, referenceWindow) as? [[CFString: Any]])?.compactMap(CGWindowValue.init) ?? []
      },
      checkCaptureAccess: CGPreflightScreenCaptureAccess,
      requestCaptureAccess: CGRequestScreenCaptureAccess
    )
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var cgWindowClient: CGWindowClient {
    get { self[CGWindowClient.self] }
    set { self[CGWindowClient.self] = newValue }
  }
}
