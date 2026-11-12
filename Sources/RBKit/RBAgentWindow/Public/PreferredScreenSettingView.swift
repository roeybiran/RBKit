import Sharing
import SwiftUI

// MARK: - PreferredScreenSettingView

public struct PreferredScreenSettingView: View {

  // MARK: Lifecycle

  public init(label: String = "Preferred screen") {
    self.label = label
  }

  // MARK: Public

  public var body: some View {
    Picker(label, selection: Binding($preferredScreen)) {
      ForEach(PreferredScreen.allCases, id: \.self) {
        Text("Containing the \(label(for: $0))")
      }
    }
  }

  // MARK: Internal

  let label: String

  func label(for setting: PreferredScreen) -> String {
    switch setting {
    case .withKeyboardFocus:
      "focused window"
    case .withMouseCursor:
      "mouse cursor"
    case .withMenuBar:
      "menu bar"
    }
  }

  // MARK: Private

  @Shared(.rbAgentWindowPreferredScreen) private var preferredScreen = .withKeyboardFocus

}

#if DEBUG
#Preview {
  PreferredScreenSettingView()
}
#endif
