import ComposableArchitecture
import PermissionsKit
import Testing

@testable import OnboardingKit

@MainActor
struct OnboardingFeatureTests {

  @Test
  func `doneButtonClicked() with all permissions granted, should set onboarded and hide popover and stop modal`() async {
    await confirmation("setIsOnboarded called") { setIsOnboardedCalled in
      await confirmation("stopModal called") { stopModalCalled in
        let store = TestStore(
          initialState: OnboardingFeature.State(
            permissions: .init(permissions: [
              Permission(
                kind: .accessibility,
                required: true,
                reason: "foo",
                status: .granted,
              )
            ]),
            shouldShowPermissionsSection: true,
            isPopoverShown: true,
          )
        ) {
          OnboardingFeature()
        } withDependencies: { d in
          d.onboardingClient.setIsOnboarded = {
            setIsOnboardedCalled()
          }
          d.nsApplicationClient.stopModal = {
            stopModalCalled()
          }
        }

        await store.send(.doneButtonClicked) {
          $0.isPopoverShown = false
        }
      }
    }
  }

  @Test
  func `doneButtonClicked() with permissions denied, should show popover`() async {
    let store = TestStore(
      initialState: OnboardingFeature.State(
        permissions: .init(permissions: [
          Permission(
            kind: .accessibility,
            required: true,
            reason: "foo",
            status: .denied,
          )
        ]),
        shouldShowPermissionsSection: true,
      )
    ) {
      OnboardingFeature()
    }

    await store.send(.doneButtonClicked) {
      $0.isPopoverShown = true
    }
  }

  @Test
  func `isPopoverShownChanged() with false value, should update state`() async {
    let store = TestStore(
      initialState: OnboardingFeature.State(
        permissions: .init(permissions: [
          Permission(
            kind: .accessibility,
            required: true,
            reason: "foo",
            status: .denied,
          )
        ]),
        shouldShowPermissionsSection: true,
        isPopoverShown: true,
      )
    ) {
      OnboardingFeature()
    }

    await store.send(.isPopoverShownChanged(false)) {
      $0.isPopoverShown = false
    }
  }

  @Test
  func `permissions(.onAppear) with any state, should perform no operation`() async {
    let store = TestStore(
      initialState: OnboardingFeature.State(permissions: [])
    ) {
      OnboardingFeature()
    }

    await store.send(.permissions(.onAppear))
  }

}
