import ComposableArchitecture
import SwiftUI

struct PermissionRowView: View {
  let permission: PermissionRowState
  let store: StoreOf<PermissionsFeature>

  var body: some View {
    HStack {
      Image(systemName: permission.symbolName)
        .font(.system(size: 12))
        .foregroundStyle(.white)
        .frame(width: 16, height: 16)
        .background(
          RoundedRectangle(cornerRadius: 2).fill(permission.accentColor.gradient)
        )
      Text(permission.title)
      Spacer()
      Button {
        store.send(.infoButtonClicked(permission.id))
      } label: {
        Image(systemName: "info.circle").frame(width: 16)
      }
      .buttonStyle(.borderless)
      .popover(
        isPresented: .init(
          get: { permission.isInfoPopoverShown },
          set: { bool in
            store.send(.popoverToggled(permission.id, bool))
          },
        )
      ) {
        Text(permission.reason)
          .padding()
          .frame(width: 480)
          .multilineTextAlignment(.leading)
      }
      Button {
        store.send(.authorizeButtonClicked(permission.id))
      } label: {
        HStack {
          switch permission.status {
          case .granted:
            Image(systemName: "checkmark")
            Text("Granted")

          case .inProgress:
            ProgressView().controlSize(.mini)
            Text("Requested…")

          case .denied, .none:
            Text("Request Access…")
            EmptyView()
          }
        }
        .frame(width: 120)
      }
      .disabled(permission.isAuthButtonDisabled)
      .controlSize(.small)
    }
  }
}

#Preview {
  PermissionRowView(
    permission: .init(permission: .accessibility(reason: "foo")),
    store: Store(
      initialState: PermissionsFeature.State(
        permissions: [
          .accessibility(reason: "Commodo ea nostrud amet enim cillum officia incididunt."),
          .recording(
            reason: "Lorem qui mollit deserunt ullamco do dolor fugiat enim. Qui ipsum do sint. Exercitation ad minim laborum anim adipisicing aliqua pariatur."
          ),
        ]
      )
    ) {
      PermissionsFeature()
    },
  )
  .frame(width: 480)
}
