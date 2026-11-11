import AppKit
import RBKit
import SwiftUI

struct AXKitDemo: View {

  // MARK: Internal

  var body: some View {
    Form {
      Section {
        LabeledContent("Accessibility Trusted") {
          Text(isTrusted ? "Yes" : "No")
        }
        if !isTrusted {
          Button("Request Access") {
            isTrusted = client.isProcessTrusted(usePrompt: true)
          }
        }
      }

      Section {
        Picker("Application", selection: $selectedPID) {
          Text("None").tag(pid_t?.none)
          ForEach(apps, id: \.processIdentifier) { app in
            Text(app.localizedName ?? app.bundleIdentifier ?? "\(app.processIdentifier)")
              .tag(Optional(app.processIdentifier))
          }
        }
        Button("Refresh") { inspect() }
          .disabled(selectedPID == nil)
      }

      Section("Windows") {
        ForEach(windowTitles, id: \.self) { Text($0) }
      }

      Section("Menu Bar") {
        ForEach(menuTitles, id: \.self) { Text($0) }
      }

      if let errorMessage {
        Section("Error") {
          Text(errorMessage).foregroundStyle(.red)
        }
      }
    }
    .formStyle(.grouped)
    .onAppear {
      isTrusted = client.isProcessTrusted()
      apps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
    }
    .onChange(of: selectedPID) { inspect() }
  }

  // MARK: Private

  @State private var isTrusted = false
  @State private var apps = [NSRunningApplication]()
  @State private var selectedPID: pid_t?
  @State private var windowTitles = [String]()
  @State private var menuTitles = [String]()
  @State private var errorMessage: String?

  private let client = AXClientLive()

  private func inspect() {
    windowTitles = []
    menuTitles = []
    errorMessage = nil
    guard let selectedPID else { return }
    let app = client.application(pid: selectedPID)
    do {
      let windows = try client.attributeValue(element: app, for: client.windows)
      windowTitles = windows.map { (try? client.attributeValue(element: $0, for: .title)) ?? "<untitled>" }
      let menuBar = try client.attributeValue(element: app, for: client.menuBar)
      let items = try client.attributeValue(element: menuBar, for: client.children)
      menuTitles = items.compactMap { try? client.attributeValue(element: $0, for: .title) }
    } catch {
      errorMessage = "\(error)"
    }
  }
}
