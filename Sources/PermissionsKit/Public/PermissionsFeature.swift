import ComposableArchitecture
import Foundation
import RBKit
import ScreenCaptureKit

// MARK: - PermissionsFeature

@Reducer
public struct PermissionsFeature {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  @ObservableState
  public struct State: Equatable, Sendable {

    // MARK: Public

    public func allGranted() -> Bool {
      permissions.filter(\.required).allSatisfy { $0.status == .granted }
    }

    // MARK: Internal

    var permissions = IdentifiedArrayOf<PermissionRowState>()

    var sections: [Section] {
      let requiredPermissions = permissions.filter(\.required)
      let optionalPermissions = permissions.filter { !$0.required }

      var sections = [Section]()

      if !requiredPermissions.isEmpty {
        sections.append(Section(label: "Required", permissions: requiredPermissions))
      }

      if !optionalPermissions.isEmpty {
        sections.append(Section(label: "Recommended", permissions: optionalPermissions))
      }

      return sections
    }
  }

  public enum Action {
    case onAppear
    case infoButtonClicked(Permission.ID)
    case popoverToggled(Permission.ID, Bool)
    case authorizeButtonClicked(_ id: Permission.ID)
    case appearsActiveChange(_ active: Bool)
    case pollingEnded
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        recheck(&state)

      case .infoButtonClicked(let id):
        state.permissions[id: id]?.isInfoPopoverShown.toggle()

      case .popoverToggled(let id, let flag):
        state.permissions[id: id]?.isInfoPopoverShown = flag

      case .authorizeButtonClicked(let id):
        guard let permission = state.permissions[id: id]?.permission else {
          break
        }
        state.permissions[id: id]?.permission.status = .inProgress
        switch permission.kind {
        case .accessibility:
          _ = axClient.isProcessTrusted(usePrompt: true)
          return .poll(
            for: .seconds(1),
            until: { [axClient] in
              axClient.isProcessTrusted(usePrompt: false)
            },
            emit: .pollingEnded,
            id: cancelID,
            clock: clock,
          )

        case .recording:
          return .merge(
            .run { [cgWindowClient] _ in
              _ = cgWindowClient.requestScreenCaptureAccess()
            },
            .poll(
              for: .seconds(1),
              until: { [cgWindowClient] in
                cgWindowClient.preflightScreenCaptureAccess()
              },
              emit: .pollingEnded,
              id: cancelID,
              clock: clock,
            ),
          )

        case .fullDiskAccess:
          guard
            let settingsURL =
            URL(string: "x-apple.systempreferences:com.apple.preference.security?\(permission.settingsAnchor)")
          else {
            break
          }
          _ = nsWorkspaceClient.open(settingsURL)
          return .poll(
            for: .seconds(1),
            until: { [fileManagerClient] in
              Self.fullDiskAccessIsGranted(fileManagerClient)
            },
            emit: .pollingEnded,
            id: cancelID,
            clock: clock,
          )
        }

      case .pollingEnded:
        recheck(&state)

      case .appearsActiveChange(let isActive):
        if !isActive { break }
        recheck(&state)
        return .cancel(id: cancelID)
      }
      return .none
    }
  }

  // MARK: Internal

  struct Section: Equatable, Identifiable {
    let label: String
    let permissions: IdentifiedArrayOf<PermissionRowState>

    var id: String {
      label
    }
  }

  let cancelID = "poll"

  @Dependency(\.cgWindowClient) var cgWindowClient
  @Dependency(\.axClient) var axClient
  @Dependency(\.fileManagerClient) var fileManagerClient
  @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
  @Dependency(\.continuousClock) var clock

  // MARK: Private

  private static func fullDiskAccessIsGranted(_ fileManagerClient: FileManagerClient) -> Bool {
    let tccDirectory = fileManagerClient.homeDirectoryForCurrentUser()
      .appendingPathComponent("Library/Application Support/com.apple.TCC")
    return (try? fileManagerClient.contentsOfDirectory(tccDirectory, nil, [])) != nil
  }

  private func recheck(_ state: inout State) {
    for i in 0 ..< state.permissions.count {
      switch state.permissions[i].kind {
      case .accessibility:
        let granted = axClient.isProcessTrusted(usePrompt: false)
        state.permissions[i].permission.status = granted ? .granted : .denied

      case .recording:
        let granted = cgWindowClient.preflightScreenCaptureAccess()
        state.permissions[i].permission.status = granted ? .granted : .denied

      case .fullDiskAccess:
        let granted = Self.fullDiskAccessIsGranted(fileManagerClient)
        state.permissions[i].permission.status = granted ? .granted : .denied
      }
    }
  }
}

extension PermissionsFeature.State {
  public init(permissions: [Permission] = [Permission]()) {
    self.permissions = .init(permissions.map(PermissionRowState.init), uniquingIDsWith: { $1 })
  }
}
