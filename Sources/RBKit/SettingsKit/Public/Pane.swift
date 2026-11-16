import SwiftUI

// MARK: - Pane

/// A single page of the settings window, listed in the sidebar and shown in the detail column.
///
/// The content should be a `Form`. It is rendered with the grouped form style, the way
/// System Settings and Xcode present their settings: each `Section` becomes a rounded inset
/// group with an optional header and footer.
///
/// ```swift
/// Pane("General", identifier: "general", systemImage: "gearshape") {
///   Form {
///     Section("Starting Points") {
///       Toggle("Launch at login", isOn: $launchAtLogin)
///     }
///   }
/// }
/// ```
public struct Pane {

  // MARK: Lifecycle

  @MainActor
  public init(
    _ label: String,
    identifier: String,
    systemImage: String,
    @ViewBuilder content: () -> some View,
  ) {
    self.label = label
    self.identifier = identifier
    self.systemImage = systemImage
    self.content = AnyView(content())
  }

  // MARK: Public

  public let label: String
  public let identifier: String
  public let systemImage: String

  // MARK: Internal

  let content: AnyView

}
