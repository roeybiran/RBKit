import Quartz
import Dependencies
import DependenciesMacros

@DependencyClient
public struct CGWindowClient {
  public var list: (_ options: CGWindowListOption, _ referenceWindow: CGWindowID) -> [CGWindowValue] = { _, _ in [] }
}

extension CGWindowClient: DependencyKey {
  public static let liveValue: Self = {
    Self(list: { options, referenceWindow in
      // [.excludeDesktopElements, .optionOnScreenOnly]
      // kCGNullWindowID
      (CGWindowListCopyWindowInfo(options, referenceWindow) as? [[CFString: Any]])?.compactMap(CGWindowValue.init) ?? []
    })
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var cgWindowClient: CGWindowClient {
    get { self[CGWindowClient.self] }
    set { self[CGWindowClient.self] = newValue }
  }
}
