import ComposableArchitecture
import PermissionsKit
import RBAnalytics
import RBKit
import SwiftUI

@_exported import PermissionKit

// MARK: - OnboardingView

struct OnboardingView<CustomView: View>: View {

  // MARK: Lifecycle

  init(
    store: StoreOf<OnboardingFeature>,
    statusItem: NSStatusItem,
    analyticsAppID: String,
    customView: CustomView,
  ) {
    self.store = store
    self.statusItem = statusItem
    self.analyticsAppID = analyticsAppID
    self.customView = customView
  }

  // MARK: Internal

  var body: some View {
    Form {
      Section {
        EmptyView()
      } header: {
        HStack {
          Image(nsImage: .init(named: NSImage.applicationIconName) ?? NSImage())
            .resizable()
            .frame(width: 32, height: 32)
          Text("Welcome to \(String.appName)")
            .font(.title)
        }
        .frame(maxWidth: .infinity)
      }

      if !(customView is EmptyView) {
        Section {
          customView
        }
      }

      Section {
        LoginItemView()
        MenuBarExtraSettingView(statusItem: statusItem)
      }

      if store.shouldShowPermissionsSection {
        Section {
          PermissionsView(store: store.scope(state: \.permissions, action: \.permissions))
        } header: {
          Text("System Permissions:")
        } footer: {
          Text("Your data stays private at all times.")
            .foregroundStyle(.secondary)
            .font(.caption)
        }
      }

      Section {
        AnalyticsCheckbox(appID: analyticsAppID)
      }
    }
    .formStyle(.grouped)
    Divider()
    HStack {
      Spacer()
      Button("Start using \(String.appName)") {
        store.send(.doneButtonClicked)
      }
      .keyboardShortcut(.defaultAction)
      .popover(isPresented: $store.isPopoverShown.sending(\.isPopoverShownChanged)) {
        Text(store.popoverText).padding()
      }
    }
    .controlSize(.large)
    .padding()
  }

  // MARK: Private

  @Bindable private var store: StoreOf<OnboardingFeature>

  private let statusItem: NSStatusItem
  private let analyticsAppID: String
  private let customView: CustomView
}

extension OnboardingView where CustomView == EmptyView {
  init(
    store: StoreOf<OnboardingFeature>,
    statusItem: NSStatusItem,
    analyticsAppID: String,
  ) {
    self.init(
      store: store,
      statusItem: statusItem,
      analyticsAppID: analyticsAppID,
      customView: EmptyView(),
    )
  }
}

#Preview {
  let p = [
    Permission.accessibility(reason: "Bar"),
    Permission.recording(reason: "Foo", required: false),
  ]
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(permissions: p)
    ) {
      OnboardingFeature()
    },
    statusItem: NSStatusItem(),
    analyticsAppID: "telemetry-app",
  )
  .frame(height: 600)
}

#Preview("Custom view") {
  let p = [
    Permission.accessibility(reason: "Bar"),
    Permission.recording(reason: "Foo", required: false),
  ]
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(permissions: p)
    ) {
      OnboardingFeature()
    },
    statusItem: NSStatusItem(),
    analyticsAppID: "telemetry-app",
    customView: Text("Custom onboarding content"),
  )
  .frame(height: 600)
}
