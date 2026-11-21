import Foundation
import Observation

@MainActor
@Observable
final class ViewModel {

  // MARK: Internal

  struct State: Equatable {
    var isRegistered = false
    var error = false
  }

  enum Action {
    case checkboxClicked(on: Bool)
    case onAppear
    case openLoginItemsButtonClicked
  }

  var state = State()
  @ObservationIgnored var dependencies = Dependencies.live

  func send(_ action: Action) {
    switch action {
    case .onAppear:
      checkRegistrationStatus()

    case .checkboxClicked(on: let isOn):
      do {
        try isOn ? dependencies.register() : dependencies.unregister()
      } catch {
        logger.log("\(error)")
      }
      checkRegistrationStatus()

    case .openLoginItemsButtonClicked:
      _ = dependencies.openURL(URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!)
    }
  }

  // MARK: Private

  private func checkRegistrationStatus() {
    state.isRegistered = dependencies.getStatus() == .enabled
    state.error = dependencies.getStatus() == .requiresApproval
  }

}
