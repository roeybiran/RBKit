import ServiceManagement
import SwiftUI

// MARK: - LoginItemView

public struct LoginItemView: View {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var body: some View {
    Toggle(
      "Launch at login",
      isOn: Binding(
        get: { viewModel.state.isRegistered },
        set: { viewModel.send(.checkboxClicked(on: $0)) },
      ),
    )
    .popover(isPresented: $viewModel.state.error) {
      HStack {
        Text("An error has occured while applying your changes. Try doing so manually in System Settings.")
        Button("Open Login Items…") {
          viewModel.send(.openLoginItemsButtonClicked)
        }
      }
      .padding()
    }
    .onAppear {
      viewModel.send(.onAppear)
    }
  }

  // MARK: Private

  @StateObject private var viewModel = ViewModel()

}

#Preview {
  LoginItemView()
}
