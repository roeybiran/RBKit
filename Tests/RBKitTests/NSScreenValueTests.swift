import AppKit
import CoreGraphics
import Foundation
import Testing

@testable import RBKit

struct NSScreenValueTests {
  @Test
  func `ScreenDeviceDescription parser, should parse standard keys and NSScreenNumber`() {
    let dictionary: [NSDeviceDescriptionKey: Any] = [
      .resolution: NSValue(size: NSSize(width: 144, height: 144)),
      .colorSpaceName: "NSCalibratedRGBColorSpace",
      .bitsPerSample: 8,
      .isScreen: "YES",
      .isPrinter: "YES",
      .size: NSValue(size: NSSize(width: 1728, height: 1117)),
      NSDeviceDescriptionKey(rawValue: "NSScreenNumber"): NSNumber(value: 69732928),
    ]

    let parsed = ScreenDeviceDescription(deviceDescription: dictionary)

    #expect(parsed.resolution == CGSize(width: 144, height: 144))
    #expect(parsed.colorSpaceName == "NSCalibratedRGBColorSpace")
    #expect(parsed.bitsPerSample == 8)
    #expect(parsed.isScreen)
    #expect(parsed.isPrinter)
    #expect(parsed.size == CGSize(width: 1728, height: 1117))
    #expect(parsed.cgDirectDisplayID == CGDirectDisplayID(69732928))
  }

  @Test
  func `ScreenDeviceDescription parser, with missing bool keys, should set false`() {
    let dictionary: [NSDeviceDescriptionKey: Any] = [
      .resolution: NSValue(size: NSSize(width: 144, height: 144)),
      NSDeviceDescriptionKey(rawValue: "NSScreenNumber"): NSNumber(value: 12),
    ]

    let parsed = ScreenDeviceDescription(deviceDescription: dictionary)

    #expect(parsed.isScreen == false)
    #expect(parsed.isPrinter == false)
  }

  @Test
  func `NSScreenValue mock, should carry deviceDescription`() {
    let value = NSScreenValue.mock(
      deviceDescription: .init(
        resolution: CGSize(width: 1, height: 2),
        colorSpaceName: "x",
        bitsPerSample: 8,
        isScreen: true,
        isPrinter: false,
        size: CGSize(width: 3, height: 4),
        cgDirectDisplayID: 42,
      )
    )

    #expect(value.deviceDescription.cgDirectDisplayID == 42)
    #expect(value.deviceDescription.isScreen)
    #expect(value.deviceDescription.isPrinter == false)
  }
}
