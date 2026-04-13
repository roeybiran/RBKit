@preconcurrency import Carbon
import Foundation

// MARK: - TextInputSourcesClientMock

public final class TextInputSourcesClientMock: TextInputSourcesClientProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public typealias InputSourceRef = TextInputSourceMock

  public nonisolated(unsafe) var TISGetInputSourcePropertyHandler: @Sendable (
    _ inputSource: TextInputSourceMock,
    _ propertyKey: CFString,
  ) -> UnsafeMutableRawPointer? = { _, _ in nil }
  public nonisolated(unsafe) var TISCreateInputSourceListHandler: @Sendable (
    _ properties: CFDictionary,
    _ includeAllInstalled: Bool,
  ) -> Unmanaged<CFArray>? = { _, _ in
    Unmanaged.passRetained([] as CFArray)
  }

  public nonisolated(unsafe) var TISCopyCurrentKeyboardInputSourceHandler: @Sendable () -> Unmanaged<TextInputSourceMock>? = {
    nil
  }

  public nonisolated(unsafe) var TISSelectInputSourceHandler: @Sendable (_ inputSource: TextInputSourceMock) -> OSStatus = {
    _ in noErr
  }

  public func TISGetInputSourceProperty(
    _ inputSource: TextInputSourceMock,
    _ propertyKey: CFString,
  ) -> UnsafeMutableRawPointer? {
    TISGetInputSourcePropertyHandler(inputSource, propertyKey)
  }

  public func TISCreateInputSourceList(_ properties: CFDictionary, _ includeAllInstalled: Bool) -> Unmanaged<CFArray>? {
    TISCreateInputSourceListHandler(properties, includeAllInstalled)
  }

  public func TISCopyCurrentKeyboardInputSource() -> Unmanaged<TextInputSourceMock>? {
    TISCopyCurrentKeyboardInputSourceHandler()
  }

  public func TISSelectInputSource(_ inputSource: TextInputSourceMock) -> OSStatus {
    TISSelectInputSourceHandler(inputSource)
  }
}
