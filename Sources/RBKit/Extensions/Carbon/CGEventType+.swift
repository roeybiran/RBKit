import Carbon

extension CGEventType: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .null:
      "null"
    case .leftMouseDown:
      "leftMouseDown"
    case .leftMouseUp:
      "leftMouseUp"
    case .rightMouseDown:
      "rightMouseDown"
    case .rightMouseUp:
      "rightMouseUp"
    case .mouseMoved:
      "mouseMoved"
    case .leftMouseDragged:
      "leftMouseDragged"
    case .rightMouseDragged:
      "rightMouseDragged"
    case .keyDown:
      "keyDown"
    case .keyUp:
      "keyUp"
    case .flagsChanged:
      "flagsChanged"
    case .scrollWheel:
      "scrollWheel"
    case .tabletPointer:
      "tabletPointer"
    case .tabletProximity:
      "tabletProximity"
    case .otherMouseDown:
      "otherMouseDown"
    case .otherMouseUp:
      "otherMouseUp"
    case .otherMouseDragged:
      "otherMouseDragged"
    case .tapDisabledByTimeout:
      "tapDisabledByTimeout"
    case .tapDisabledByUserInput:
      "tapDisabledByUserInput"
    @unknown default:
      "<UNKNOWN>, rawValue: \(rawValue)"
    }
  }
}
