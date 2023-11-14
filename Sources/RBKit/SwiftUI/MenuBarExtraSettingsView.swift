import AppKit
import SwiftUI

// MARK: - MenuBarExtraSettingsView

public struct MenuBarExtraSettingsView: View {

  // MARK: Lifecycle

  public init(statusItem: NSStatusItem, helpText: String? = nil) {
    self.statusItem = statusItem
    self.helpText = helpText
    isChecked = statusItem.isVisible
  }

  // MARK: Public

  public var body: some View {
    Toggle(isOn: $isChecked) {
      Text("Show Menu Bar Extra")
      helpText.map { Text($0).foregroundColor(.secondary) }
    }
    .onChange(of: isChecked) { newValue in
      statusItem.isVisible = newValue
    }
  }

  // MARK: Internal

  let helpText: String?

  // MARK: Private

  private let statusItem: NSStatusItem
  @State private var isChecked: Bool

}

// MARK: - MenuBarExtraSettingsView_Previews

struct MenuBarExtraSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    Form {
      MenuBarExtraSettingsView(
        statusItem: NSStatusItem(),
        helpText: "When hiding the menu bar extra, the app remains accessible from the Finder.")
    }.settingsStyle()
  }
}
