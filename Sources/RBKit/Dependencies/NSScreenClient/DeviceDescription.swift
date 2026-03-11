import AppKit.NSWindow
import CoreGraphics
import Foundation

// MARK: - DeviceDescription

public protocol DeviceDescription: Sendable, Equatable {
  var resolution: CGSize? { get }
  var colorSpaceName: String? { get }
  var bitsPerSample: Int? { get }
  var isScreen: Bool { get }
  var isPrinter: Bool { get }
  var size: CGSize? { get }
}

// MARK: - ScreenDeviceDescription

public struct ScreenDeviceDescription: DeviceDescription {

  // MARK: Lifecycle

  public init(
    resolution: CGSize? = nil,
    colorSpaceName: String? = nil,
    bitsPerSample: Int? = nil,
    isScreen: Bool = false,
    isPrinter: Bool = false,
    size: CGSize? = nil,
    cgDirectDisplayID: CGDirectDisplayID? = nil,
  ) {
    self.resolution = resolution
    self.colorSpaceName = colorSpaceName
    self.bitsPerSample = bitsPerSample
    self.isScreen = isScreen
    self.isPrinter = isPrinter
    self.size = size
    self.cgDirectDisplayID = cgDirectDisplayID
  }

  public init(deviceDescription: [NSDeviceDescriptionKey: Any]) {
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
