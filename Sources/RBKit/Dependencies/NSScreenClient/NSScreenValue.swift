import AppKit.NSScreen
import Foundation

// MARK: - Screen

public struct NSScreenValue: Equatable {
  // Getting Screen Information
  let depth: NSWindow.Depth
  let frame: NSRect
  // var supportedWindowDepths: UnsafePointer<NSWindow.Depth>
  // var deviceDescription: [NSDeviceDescriptionKey : Any]
  // struct NSDeviceDescriptionKey
  // var colorSpace: NSColorSpace?
  let localizedName: String
  // func canRepresent(NSDisplayGamut) -> Bool
  // class var screensHaveSeparateSpaces: Bool

  // Converting Between Screen and Backing Coordinates
  // func backingAlignedRect(NSRect, options: AlignmentOptions) -> NSRect
  let backingScaleFactor: CGFloat
  // func convertRectFromBacking(NSRect) -> NSRect
  // func convertRectToBacking(NSRect) -> NSRect
  // Getting the Visible Portion of the Screen
  let visibleFrame: NSRect
  // let safeAreaInsets: NSEdgeInsets
  let auxiliaryTopLeftArea: NSRect?
  let auxiliaryTopRightArea: NSRect?

  // Getting Extended Dynamic Range Details
  let maximumPotentialExtendedDynamicRangeColorComponentValue: CGFloat
  let maximumExtendedDynamicRangeColorComponentValue: CGFloat
  let maximumReferenceExtendedDynamicRangeColorComponentValue: CGFloat

  // Getting Variable Refresh Rate Details
  let maximumFramesPerSecond: Int
  let minimumRefreshInterval: TimeInterval
  let maximumRefreshInterval: TimeInterval
  let displayUpdateGranularity: TimeInterval
  let lastDisplayUpdateTimestamp: TimeInterval

  // Receiving Screen-Related Notifications
  // class let colorSpaceDidChangeNotification: NSNotification.Name

  // Synchronizing with the display’s refresh rate
  // func displayLink(target: Any, selector: Selector) -> CADisplayLink
}

extension NSScreenValue {
  init(nsScreen: NSScreen) {
    depth = nsScreen.depth
    frame = nsScreen.frame
    localizedName = nsScreen.localizedName
    backingScaleFactor = nsScreen.backingScaleFactor
    visibleFrame = nsScreen.visibleFrame
    // safeAreaInsets = nsScreen.safeAreaInsets
    auxiliaryTopLeftArea = nsScreen.auxiliaryTopLeftArea
    auxiliaryTopRightArea = nsScreen.auxiliaryTopRightArea
    maximumPotentialExtendedDynamicRangeColorComponentValue = nsScreen.maximumPotentialExtendedDynamicRangeColorComponentValue
    maximumExtendedDynamicRangeColorComponentValue = nsScreen.maximumExtendedDynamicRangeColorComponentValue
    maximumReferenceExtendedDynamicRangeColorComponentValue = nsScreen.maximumReferenceExtendedDynamicRangeColorComponentValue
    maximumFramesPerSecond = nsScreen.maximumFramesPerSecond
    minimumRefreshInterval = nsScreen.minimumRefreshInterval
    maximumRefreshInterval = nsScreen.maximumRefreshInterval
    displayUpdateGranularity = nsScreen.displayUpdateGranularity
    lastDisplayUpdateTimestamp = nsScreen.lastDisplayUpdateTimestamp
  }
}

