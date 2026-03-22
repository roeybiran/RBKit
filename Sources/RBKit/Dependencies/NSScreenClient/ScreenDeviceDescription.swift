import AppKit.NSWindow
import CoreGraphics

// MARK: - ScreenDeviceDescription

public struct ScreenDeviceDescription: DeviceDescriptionProtocol {

  // Swift keeps synthesized memberwise initializers internal for public
  // structs, so expose the same shape explicitly for public mocks/defaults.
  public init(
    resolution: CGSize?,
    colorSpaceName: String?,
    bitsPerSample: Int?,
    isScreen: Bool,
    isPrinter: Bool,
    size: CGSize?,
    cgDirectDisplayID: CGDirectDisplayID?,
  ) {
    self.resolution = resolution
    self.colorSpaceName = colorSpaceName
    self.bitsPerSample = bitsPerSample
    self.isScreen = isScreen
    self.isPrinter = isPrinter
    self.size = size
    self.cgDirectDisplayID = cgDirectDisplayID
  }

  init(deviceDescription: [NSDeviceDescriptionKey: Any]) {
    resolution = deviceDescription[.resolution] as? CGSize
    colorSpaceName = deviceDescription[.colorSpaceName] as? String
    bitsPerSample = deviceDescription[.bitsPerSample] as? Int
    isScreen = deviceDescription[.isScreen] != nil
    isPrinter = deviceDescription[.isPrinter] != nil
    size = deviceDescription[.size] as? CGSize
    cgDirectDisplayID = deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID
  }

  // MARK: Public

  public let resolution: CGSize?
  public let colorSpaceName: String?
  public let bitsPerSample: Int?
  public let isScreen: Bool
  public let isPrinter: Bool
  public let size: CGSize?
  public let cgDirectDisplayID: CGDirectDisplayID?

}
