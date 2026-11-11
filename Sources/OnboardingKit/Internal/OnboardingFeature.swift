import AppKit
import ComposableArchitecture
import Foundation
import PermissionKit
import PermissionsKit
import RBKit

// MARK: - OnboardingFeature

@Reducer
struct OnboardingFeature {

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Sendable {
    let popoverText = "All required permissions must be granted."

    var permissions: PermissionsFeature.State
    let shouldShowPermissionsSection: Bool
    var isPopoverShown = false
  }

  enum Action {
    case permissions(PermissionsFeature.Action)
    case isPopoverShownChanged(Bool)
    case doneButtonClicked
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.permissions, action: \.permissions) {
      PermissionsFeature()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case .isPopoverShownChanged(let flag):
        state.isPopoverShown = flag

      case .doneButtonClicked:
        if state.permissions.allGranted() {
          onboardingClient.setIsOnboarded()
          state.isPopoverShown = false
          return .run { _ in
            await nsApplicationClient.stopModal()
          }
        } else {
          state.isPopoverShown = true
        }

      case .permissions:
        break
      }

      return .none
    }
  }

  // MARK: Private

  @Dependency(\.nsApplicationClient) private var nsApplicationClient
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  @Dependency(\.onboardingClient) private var onboardingClient

}

extension OnboardingFeature.State {
  init(permissions: [Permission]) {
    self.permissions = PermissionsFeature.State(permissions: permissions)
    shouldShowPermissionsSection = !permissions.isEmpty
  }
}
