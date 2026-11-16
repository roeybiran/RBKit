import SwiftUI

// MARK: - SettingsView

/// The settings window's content: a sidebar of panes next to the selected pane, or just the
/// pane when there is only one.
struct SettingsView: View {

  // MARK: Internal

  @Bindable var model: SettingsModel

  var body: some View {
    if model.panes.count > 1 {
      NavigationSplitView {
        List(model.panes, selection: $model.selection) { pane in
          NavigationLink(value: pane.id) {
            Label(pane.label, systemImage: pane.systemImage)
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

  /// The selected pane's label when there is a sidebar to pick from, else the app's name.
  private var title: String {
    if model.panes.count > 1, let pane = model.selectedPane {
      pane.label
    } else {
      "\(Bundle.main.appName) Settings"
    }
  }

  private var detail: some View {
    Group {
      if let pane = model.selectedPane {
        pane.content
          .formStyle(.grouped)
          .id(pane.id)
      } else {
        ContentUnavailableView("No Selection", systemImage: "sidebar.left")
      }
    }
    .navigationTitle(title)
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
