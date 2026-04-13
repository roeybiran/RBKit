@preconcurrency import Carbon

// MARK: - TextInputSourcesClientProtocol

public protocol TextInputSourcesClientProtocol: Sendable {
  associatedtype InputSourceRef: AnyObject

  func TISGetInputSourceProperty(_ inputSource: InputSourceRef, _ propertyKey: CFString) -> UnsafeMutableRawPointer?
  func TISCreateInputSourceList(_ properties: CFDictionary, _ includeAllInstalled: Bool) -> Unmanaged<CFArray>?
  func TISCopyCurrentKeyboardInputSource() -> Unmanaged<InputSourceRef>?
  func TISSelectInputSource(_ inputSource: InputSourceRef) -> OSStatus
}
