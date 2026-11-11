import SwiftUI

public struct Permission: Hashable, Identifiable, Sendable {

  // MARK: Lifecycle

  public init(kind: Kind, required: Bool = true, reason: String, status: Status? = nil) {
    self.kind = kind
    self.reason = reason
    self.required = required
    self.status = status
  }

  // MARK: Public

  public enum Kind: Int, Sendable {
    case accessibility
    case recording
    case fullDiskAccess
  }

  public enum Status: Sendable {
    case inProgress
    case granted
    case denied
  }

  public var id: Kind {
    kind
  }

  public var settingsAnchor: String {
    switch kind {
    case .accessibility:
      "Privacy_Accessibility"
    case .recording:
      "Privacy_ScreenCapture"
    case .fullDiskAccess:
      "Privacy_AllFiles"
    }
  }

  public static func accessibility(reason: String, required: Bool = true) -> Self {
    self.init(kind: .accessibility, required: required, reason: reason)
  }

  public static func recording(reason: String, required: Bool = true) -> Self {
    self.init(kind: .recording, required: required, reason: reason)
  }

  public static func fullDiskAccess(reason: String, required: Bool = true) -> Self {
    self.init(kind: .fullDiskAccess, required: required, reason: reason)
  }

  // MARK: Internal

  let kind: Kind
  let reason: String
  let required: Bool
  var status: Status?

  var title: String {
    switch kind {
    case .accessibility:
      "Accessibility"
    case .recording:
      "Screen & System Audio Recording"
    case .fullDiskAccess:
      "Full Disk Access"
    }
  }

  var symbolName: String {
    switch kind {
    case .accessibility:
      "accessibility"
    case .recording:
      "record.circle"
    case .fullDiskAccess:
      "externaldrive"
    }
  }

  var accentColor: Color {
    switch kind {
    case .accessibility:
      .blue
    case .recording:
      .red
    case .fullDiskAccess:
      .gray
    }
  }

}
