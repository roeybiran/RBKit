import AppKit
import SwiftUI

// MARK: - MenuBarExtraSettingView

public struct MenuBarExtraSettingView: View {

  // MARK: Lifecycle

  public init(statusItem: NSStatusItem) {
    viewModel = MenuBarExtraSettingViewModel(statusItem: statusItem)
  }

  // MARK: Public

  public var body: some View {
    VStack {
      Toggle(
        "Show menu bar extra",
        isOn: Binding(
          get: {
            viewModel.isVisible
          },
          set: {
            viewModel.checkboxClicked(isOn: $0)
          },
        ),
      )
    }
  }

  // MARK: Private

  @State private var viewModel: MenuBarExtraSettingViewModel

}

// MARK: - MenuBarExtraSettingViewModel

@MainActor
@Observable
final class MenuBarExtraSettingViewModel {

  // MARK: Lifecycle

  init(statusItem: NSStatusItem) {
    self.statusItem = statusItem
    isVisible = statusItem.isVisible
  }

  // MARK: Internal

  var isVisible: Bool

  func checkboxClicked(isOn: Bool) {
    isVisible = isOn
    statusItem.isVisible = isOn
  }

  // MARK: Private

  private let statusItem: NSStatusItem
}

#Preview {
  MenuBarExtraSettingView(statusItem: NSStatusItem())
}
