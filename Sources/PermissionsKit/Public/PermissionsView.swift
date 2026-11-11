import ComposableArchitecture
import SwiftUI

public struct PermissionsView: View {

  // MARK: Lifecycle

  public init(store: StoreOf<PermissionsFeature>) {
    self.store = store
  }

  public init(_ permissions: [Permission]) {
    store = Store(initialState: PermissionsFeature.State(permissions: permissions)) {
      PermissionsFeature()
    }
  }

  // MARK: Public

  public var body: some View {
    List {
      ForEach(store.sections) { section in
        Section(section.label) {
          ForEach(section.permissions) { permission in
            PermissionRowView(
              permission: permission,
              store: store,
            )
          }
        }
        .listRowSeparator(.hidden)
      }
      .listStyle(.plain)
    }
    .onChange(of: appearsActive) {
      store.send(.appearsActiveChange(appearsActive))
    }
  }

  // MARK: Internal

  @Bindable var store: StoreOf<PermissionsFeature>

  @Environment(\.appearsActive) var appearsActive

}

#Preview {
  Form {
    Section("Permissions") {
      PermissionsView(
        store: Store(
          initialState: PermissionsFeature.State(
            permissions: [
              .accessibility(reason: "For resizing and moving windows."),
              .recording(reason: "For displaying window previews.", required: false),
            ]
          )
        ) {
          PermissionsFeature()
        }
      )
    }
  }
  .formStyle(.grouped)
  .fixedSize(horizontal: false, vertical: true)
  .frame(width: 480)
}
