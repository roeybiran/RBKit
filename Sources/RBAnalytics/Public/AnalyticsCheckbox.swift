import RBKit
import SwiftUI

public struct AnalyticsCheckbox: View {

  // MARK: Lifecycle

  public init(appID: String) {
    viewModel = AnalyticsCheckboxViewModel(appID: appID)
  }

  // MARK: Public

  public var body: some View {
    Toggle(
      isOn: Binding(
        get: {
          viewModel.isEnabled
        },
        set: {
          viewModel.checkboxClicked(isOn: $0)
        },
      )
    ) {
      Text("Share app analytics")
      Text("Analytics are completely anonymous and used only for product improvements.")
    }
  }

  // MARK: Private

  @State private var viewModel: AnalyticsCheckboxViewModel
}
