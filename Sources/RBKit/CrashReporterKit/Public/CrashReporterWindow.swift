import AppKit
import Dependencies
import SwiftUI

@MainActor
public final class CrashReporterWindow {
  public static func showModalIfNeeded(email: String) {
    @Dependency(\.crashReporterClient) var crashReporterClient
    guard let report = crashReporterClient.mostRecent() else { return }
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled],
      backing: .buffered,
      defer: true,
    )
    let viewModel = CrashReporterViewModel(report: report, email: email)
    let view = CrashReporterView(viewModel: viewModel).padding()
    let hostingController = NSHostingController(rootView: view)
    hostingController.preferredContentSize = .init(width: 1000, height: 800) // like the system's crash reporter
    window.contentViewController = hostingController
    window.isReleasedWhenClosed = false // crashes otherwise!
    _ = NSApplication.shared.runModal(for: window)
    window.close()
  }
}
