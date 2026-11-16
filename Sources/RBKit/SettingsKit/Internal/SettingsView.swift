import SwiftUI

// MARK: - SettingsView

/// The settings window's content: a sidebar of panes next to the selected pane, or just the
/// pane when there is only one.
struct SettingsView: View {

  // MARK: Internal

  let model: SettingsModel

  var body: some View {
    if model.panes.count > 1 {
      NavigationSplitView {
        List(selection: selection) {
          ForEach(model.panes, id: \.identifier) { pane in
            Label(pane.label, systemImage: pane.systemImage)
              .tag(pane.identifier)
          }
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 280)
        .toolbar(removing: .sidebarToggle)
      } detail: {
        detail
          .toolbar {
            ToolbarItemGroup(placement: .navigation) {
              Button("Back", systemImage: "chevron.backward", action: model.goBack)
                .disabled(!model.canGoBack)
                .keyboardShortcut("[", modifiers: .command)
              Button("Forward", systemImage: "chevron.forward", action: model.goForward)
                .disabled(!model.canGoForward)
                .keyboardShortcut("]", modifiers: .command)
            }
          }
      }
    } else {
      detail
    }
  }

  // MARK: Private

  private var selection: Binding<String?> {
    Binding(
      get: { model.selectedPane?.identifier },
      set: { identifier in
        // A source list always has a selection; ignore attempts to clear it.
        guard let identifier else { return }
        model.select(identifier: identifier)
      },
    )
  }

  @ViewBuilder
  private var detail: some View {
    if let pane = model.selectedPane {
      pane.content
        .formStyle(.grouped)
        .id(pane.identifier)
    }
  }

}

#Preview {
  @Previewable @State var isOn = true

  let model = SettingsModel()
  model.setPanes([
    Pane("General", identifier: "general", systemImage: "gearshape") {
      Form {
        Section("Starting Points") {
          Toggle(isOn: $isOn) {
            Text("Restore open windows")
            Text("Reopens the windows that were open when you quit.")
          }
        }
      }
    },
    Pane("Appearance", identifier: "appearance", systemImage: "circle.lefthalf.filled") {
      Form {
        Toggle("Show icons", isOn: $isOn)
      }
    },
  ])
  return SettingsView(model: model)
    .frame(width: 720, height: 480)
}
