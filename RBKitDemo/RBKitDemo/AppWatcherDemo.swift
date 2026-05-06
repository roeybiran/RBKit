import Dependencies
import Foundation
import RBKit
import SwiftUI

struct AppWatcherDemo: View {
  @Dependency(\.appWatcherClient) private var appWatcherClient

  @State private var logs = [String]()
  @State private var task: Task<Void, Never>?

  var body: some View {
    Section {
      List(Array(logs.enumerated()), id: \.offset) { _, log in
        Text(log)
          .font(.system(.body, design: .monospaced))
          .textSelection(.enabled)
      }
      .frame(minHeight: 220)
    } header: {
      HStack {
        Text("AppWatcher")
        Spacer()
        Button("Cancel Stream") {
          task?.cancel()
          logs.append("cancelled")
        }.disabled(task == nil)
      }
    }
    .task {
      startTask()
    }
    .onDisappear {
      task?.cancel()
    }
  }

  private func startTask() {
    task = Task {
      for await event in appWatcherClient.events() {
        switch event {
        case .launched(let apps):
          let names = apps.map { $0.localizedName ?? "UNKNOWN" }.joined(separator: ", ")
          logs.append("launched: \(names)")

        case .didFinishedLaunching(let app):
          handleRunningAppEvent("didFinishedLaunching", app: app)

        case .activated(let app):
          handleRunningAppEvent("activated", app: app)

        case .deactivated(let app):
          handleRunningAppEvent("deactivated", app: app)

        case .ownedMenuBar(let app):
          handleRunningAppEvent("ownedMenuBar", app: app)

        case .disownedMenuBar(let app):
          handleRunningAppEvent("disownedMenuBar", app: app)

        case .terminated(let app):
          handleRunningAppEvent("terminated", app: app)

        case .hidden(let app):
          handleRunningAppEvent("hidden", app: app)

        case .unhidden(let app):
          handleRunningAppEvent("unhidden", app: app)

        case .activationPolicyChanged(let app):
          handleRunningAppEvent("activationPolicyChanged", app: app)
        }

        if logs.count > 200 {
          logs.removeFirst(logs.count - 200)
        }
      }
    }
  }

  private func handleRunningAppEvent(_ event: String, app: NSRunningApplication) {
    logs.append("\(event): \(app.localizedName ?? "UNKNOWN")")
  }
}
