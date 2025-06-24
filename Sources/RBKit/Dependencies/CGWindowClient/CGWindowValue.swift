import Foundation
import Quartz

// MARK: - CGWindowValue

// https://gist.github.com/stephancasas/d230ac93d5bc1b0130555e2bc7203fce

public struct CGWindowValue: Hashable, Sendable {
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
