import Dependencies
import DependenciesMacros
import Quartz

// MARK: - CGWindowClient

@DependencyClient
public struct CGWindowClient: Sendable {
  public var copyWindowInfo: @Sendable (_ options: CGWindowListOption, _ referenceWindow: CGWindowID) -> CFArray?
  // https://github.com/nonstrict-hq/ScreenCaptureKit-Recording-example/blob/main/Sources/sckrecording/main.swift
  public var preflightScreenCaptureAccess: @Sendable () -> Bool = { false }
  public var requestScreenCaptureAccess: @Sendable () -> Bool = { false }

  public func list(
    options: CGWindowListOption = [.excludeDesktopElements],
    referenceWindow: CGWindowID = kCGNullWindowID
  ) -> [CGWindowValue] {
    let info = copyWindowInfo(options: options, referenceWindow: referenceWindow) as? [[CFString: Any]]
    return info?.compactMap(CGWindowValue.init) ?? []
  }
}

// MARK: DependencyKey

extension CGWindowClient: DependencyKey {
  public static let liveValue = Self(
    copyWindowInfo: CGWindowListCopyWindowInfo,
    preflightScreenCaptureAccess: CGPreflightScreenCaptureAccess,
    requestScreenCaptureAccess: CGRequestScreenCaptureAccess
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var cgWindowClient: CGWindowClient {
    get { self[CGWindowClient.self] }
    set { self[CGWindowClient.self] = newValue }
  }
}

extension CGWindowValue {
  init?(_ dictionary: [CFString: Any]) {
    // https://developer.apple.com/documentation/coregraphics/quartz_window_services/required_window_list_keys
    guard let number = dictionary[kCGWindowNumber] as? CGWindowID else { return nil }
    guard let storeType = dictionary[kCGWindowStoreType] as? Int else { return nil }
    guard let layer = dictionary[kCGWindowLayer] as? Int32 else { return nil }
    guard let boundsDictRep = dictionary[kCGWindowBounds] as? [String: CGFloat] else { return nil }
    guard let x = boundsDictRep["X"] else { return nil }
    guard let y = boundsDictRep["Y"] else { return nil }
    guard let w = boundsDictRep["Width"] else { return nil }
    guard let h = boundsDictRep["Height"] else { return nil }
    guard let sharingState = dictionary[kCGWindowSharingState] as? Int else { return nil }
    guard let alpha = dictionary[kCGWindowAlpha] as? CGFloat else { return nil }
    guard let ownerPID = dictionary[kCGWindowOwnerPID] as? pid_t else { return nil }
    guard let memoryUsage = dictionary[kCGWindowMemoryUsage] as? Int else { return nil }

    self.number = number
    self.storeType = storeType
    self.layer = layer
    bounds = CGRect(x: x, y: y, width: w, height: h)
    self.sharingState = sharingState
    self.alpha = alpha
    self.ownerPID = ownerPID
    self.memoryUsage = memoryUsage

    // https://developer.apple.com/documentation/coregraphics/quartz_window_services/optional_window_list_keys
    // self.workspace = dictionary[kCGWindowWorkspace] as? Int32
    ownerName = dictionary[kCGWindowOwnerName] as? String
    name = dictionary[kCGWindowName] as? String
    isOnscreen = dictionary[kCGWindowIsOnscreen] as? Bool
    backingLocationVideoMemory = dictionary[kCGWindowBackingLocationVideoMemory] as? Bool
  }
}
