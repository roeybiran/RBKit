import AppKit
import UniformTypeIdentifiers

// MARK: - NSImageDescriptor

public enum NSImageDescriptor: Hashable, Sendable {
  case name(String)
  case systemSymbol(name: String, accessibilityDescription: String?)
  case contentType(UTType)
  case path(String)
}

extension NSImage {
  public static func from(descriptor: NSImageDescriptor, workspace: NSWorkspace = .shared)
    -> NSImage?
  {
    switch descriptor {
    case .name(let name):
      NSImage(named: name)
    case .systemSymbol(let systemSymbolName, let accessibilityDescription):
      NSImage(
        systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
    case .contentType(let contentType):
      workspace.icon(for: contentType)
    case .path(let path):
      workspace.icon(forFile: path)
    }
  }
}
