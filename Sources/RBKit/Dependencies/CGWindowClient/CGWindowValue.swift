import Foundation
import Quartz

// MARK: - CGWindow

// https://gist.github.com/stephancasas/d230ac93d5bc1b0130555e2bc7203fce

public struct CGWindowValue {
  // CGWindow.h:44
  public let number: CGWindowID
  public let storeType: Int
  public let layer: Int32
  public let bounds: CGRect
  public let sharingState: Int
  public let alpha: CGFloat
  public let ownerPID: pid_t
  public let memoryUsage: Int

  // let workspace: Int32?
  public let ownerName: String?
  public let name: String?
  public let isOnscreen: Bool?
  public let backingLocationVideoMemory: Bool?
}

extension CGWindowValue: Equatable { }

extension CGWindowValue {
  public init?(_ dictionary: [CFString: Any]) {
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
    self.bounds = CGRect(x: x, y: y, width: w, height: h)
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
