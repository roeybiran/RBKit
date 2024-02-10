import AppKit.NSScreen
import Foundation

// MARK: - Screen

public struct NSScreenValue {
  // Getting Screen Information
  public let depth: NSWindow.Depth
  public let frame: NSRect
  // var supportedWindowDepths: UnsafePointer<NSWindow.Depth>
  // var deviceDescription: [NSDeviceDescriptionKey : Any]
  // struct NSDeviceDescriptionKey
  // var colorSpace: NSColorSpace?
  public let localizedName: String
  // func canRepresent(NSDisplayGamut) -> Bool
  // class var screensHaveSeparateSpaces: Bool

  // Converting Between Screen and Backing Coordinates
  // func backingAlignedRect(NSRect, options: AlignmentOptions) -> NSRect
  public let backingScaleFactor: CGFloat
  // func convertRectFromBacking(NSRect) -> NSRect
  // func convertRectToBacking(NSRect) -> NSRect
  // Getting the Visible Portion of the Screen
  public let visibleFrame: NSRect
  // let safeAreaInsets: NSEdgeInsets
  public let auxiliaryTopLeftArea: NSRect?
  public let auxiliaryTopRightArea: NSRect?

  // Getting Extended Dynamic Range Details
  public let maximumPotentialExtendedDynamicRangeColorComponentValue: CGFloat
  public let maximumExtendedDynamicRangeColorComponentValue: CGFloat
  public let maximumReferenceExtendedDynamicRangeColorComponentValue: CGFloat

  // Getting Variable Refresh Rate Details
  public let maximumFramesPerSecond: Int
  public let minimumRefreshInterval: TimeInterval
  public let maximumRefreshInterval: TimeInterval
  public let displayUpdateGranularity: TimeInterval
  public let lastDisplayUpdateTimestamp: TimeInterval

  // Receiving Screen-Related Notifications
  // class let colorSpaceDidChangeNotification: NSNotification.Name

  // Synchronizing with the display’s refresh rate
  // func displayLink(target: Any, selector: Selector) -> CADisplayLink

  public init(
    depth: NSWindow.Depth,
    frame: NSRect,
    localizedName: String,
    backingScaleFactor: CGFloat,
    visibleFrame: NSRect,
    auxiliaryTopLeftArea: NSRect?,
    auxiliaryTopRightArea: NSRect?,
    maximumPotentialExtendedDynamicRangeColorComponentValue: CGFloat,
    maximumExtendedDynamicRangeColorComponentValue: CGFloat,
    maximumReferenceExtendedDynamicRangeColorComponentValue: CGFloat,
    maximumFramesPerSecond: Int,
    minimumRefreshInterval: TimeInterval,
    maximumRefreshInterval: TimeInterval,
    displayUpdateGranularity: TimeInterval,
    lastDisplayUpdateTimestamp: TimeInterval
  ) {
    self.depth = depth
    self.frame = frame
    self.localizedName = localizedName
    self.backingScaleFactor = backingScaleFactor
    self.visibleFrame = visibleFrame
    self.auxiliaryTopLeftArea = auxiliaryTopLeftArea
    self.auxiliaryTopRightArea = auxiliaryTopRightArea
    self.maximumPotentialExtendedDynamicRangeColorComponentValue = maximumPotentialExtendedDynamicRangeColorComponentValue
    self.maximumExtendedDynamicRangeColorComponentValue = maximumExtendedDynamicRangeColorComponentValue
    self.maximumReferenceExtendedDynamicRangeColorComponentValue = maximumReferenceExtendedDynamicRangeColorComponentValue
    self.maximumFramesPerSecond = maximumFramesPerSecond
    self.minimumRefreshInterval = minimumRefreshInterval
    self.maximumRefreshInterval = maximumRefreshInterval
    self.displayUpdateGranularity = displayUpdateGranularity
    self.lastDisplayUpdateTimestamp = lastDisplayUpdateTimestamp
  }
}

extension NSScreenValue: Equatable {}

extension NSScreenValue {
  public init(nsScreen: NSScreen) {
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

#if DEBUG
extension NSScreenValue {
  public static func mock(
    depth: NSWindow.Depth = .sixtyfourBitRGB,
    frame: NSRect = .zero,
    localizedName: String = "foo",
    backingScaleFactor: CGFloat = .zero,
    visibleFrame: NSRect = .zero,
    auxiliaryTopLeftArea: NSRect? = nil,
    auxiliaryTopRightArea: NSRect? = nil,
    maximumPotentialExtendedDynamicRangeColorComponentValue: CGFloat = .zero,
    maximumExtendedDynamicRangeColorComponentValue: CGFloat = .zero,
    maximumReferenceExtendedDynamicRangeColorComponentValue: CGFloat = .zero,
    maximumFramesPerSecond: Int = 0,
    minimumRefreshInterval: TimeInterval = 0,
    maximumRefreshInterval: TimeInterval = 0,
    displayUpdateGranularity: TimeInterval = 0,
    lastDisplayUpdateTimestamp: TimeInterval = 0
  ) -> Self {
    .init(
      depth: depth,
      frame: frame,
      localizedName: localizedName,
      backingScaleFactor: backingScaleFactor,
      visibleFrame: visibleFrame,
      auxiliaryTopLeftArea: auxiliaryTopLeftArea,
      auxiliaryTopRightArea: auxiliaryTopRightArea,
      maximumPotentialExtendedDynamicRangeColorComponentValue: maximumPotentialExtendedDynamicRangeColorComponentValue,
      maximumExtendedDynamicRangeColorComponentValue: maximumExtendedDynamicRangeColorComponentValue,
      maximumReferenceExtendedDynamicRangeColorComponentValue: maximumReferenceExtendedDynamicRangeColorComponentValue,
      maximumFramesPerSecond: maximumFramesPerSecond,
      minimumRefreshInterval: minimumRefreshInterval,
      maximumRefreshInterval: maximumRefreshInterval,
      displayUpdateGranularity: displayUpdateGranularity,
      lastDisplayUpdateTimestamp: lastDisplayUpdateTimestamp
    )
  }
}
#endif

