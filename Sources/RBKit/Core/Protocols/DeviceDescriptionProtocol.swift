import CoreGraphics

// MARK: - DeviceDescriptionProtocol

public protocol DeviceDescriptionProtocol: Sendable, Equatable {
  var resolution: CGSize? { get }
  var colorSpaceName: String? { get }
  var bitsPerSample: Int? { get }
  var isScreen: Bool { get }
  var isPrinter: Bool { get }
  var size: CGSize? { get }
}
