@preconcurrency import Carbon
import Foundation

// MARK: - TextInputSourcesClientLive

public struct TextInputSourcesClientLive: TextInputSourcesClientProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public typealias InputSourceRef = TISInputSource

  public func TISGetInputSourceProperty(
    _ inputSource: TISInputSource,
    _ propertyKey: CFString,
  ) -> UnsafeMutableRawPointer? {
    Carbon.TISGetInputSourceProperty(inputSource, propertyKey)
  }

  public func TISCreateInputSourceList(_ properties: CFDictionary, _ includeAllInstalled: Bool) -> Unmanaged<CFArray>? {
    Carbon.TISCreateInputSourceList(properties, includeAllInstalled)
  }

  public func TISCopyCurrentKeyboardInputSource() -> Unmanaged<TISInputSource>? {
    Carbon.TISCopyCurrentKeyboardInputSource()
  }

  public func TISSelectInputSource(_ inputSource: TISInputSource) -> OSStatus {
    Carbon.TISSelectInputSource(inputSource)
  }
}
