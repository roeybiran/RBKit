import AppKit
import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct OpenPanelClient: Sendable {
  public var run: @MainActor @Sendable () -> (NSApplication.ModalResponse, [URL]) = { (.OK, []) }
}

extension OpenPanelClient: DependencyKey {
  public static let liveValue: Self = {
    .init {
      let panel = NSOpenPanel()
      panel.allowsMultipleSelection = true
      panel.allowedContentTypes = [.applicationBundle]
      panel.allowsOtherFileTypes = false
      panel.directoryURL = try? FileManager.default.url(
        for: .applicationDirectory,
        in: .systemDomainMask,
        appropriateFor: nil,
        create: false)

      let result = panel.runModal()
      return (result, panel.urls)
    }
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var openPanelClient: OpenPanelClient {
    get { self[OpenPanelClient.self] }
    set { self[OpenPanelClient.self] = newValue }
  }
}

