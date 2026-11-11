import Sparkle
import SwiftUI

// MARK: - UpdatesSettingsView

// https://sparkle-project.org/documentation/preferences-ui/#adding-settings-in-swiftui

public struct UpdatesSettingsView: View {

  // MARK: Lifecycle

  init(
    updater: SPUUpdater,
    label: String = "Software Updates:",
  ) {
    self.updater = updater
    self.label = label
    automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
    automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
  }

  // MARK: Public

  public var body: some View {
    LabeledContent(label) {
      VStack {
        Toggle("Automatically check for updates", isOn: $automaticallyChecksForUpdates)
          .onChange(of: automaticallyChecksForUpdates) {
            updater.automaticallyChecksForUpdates = automaticallyChecksForUpdates
          }
        Toggle("Automatically download updates", isOn: $automaticallyDownloadsUpdates)
          .disabled(!automaticallyChecksForUpdates)
          .onChange(of: automaticallyDownloadsUpdates) {
            updater.automaticallyDownloadsUpdates = automaticallyDownloadsUpdates
          }
      }
    }
  }

  // MARK: Internal

  let label: String

  // MARK: Private

  @State private var automaticallyChecksForUpdates: Bool
  @State private var automaticallyDownloadsUpdates: Bool

  private let updater: SPUUpdater
}

extension UpdatesSettingsView {
  public init(label: String = "Software Updates:") {
    let updater = SparkleController.shared.updaterController.updater
    self.updater = updater
    self.label = label
    automaticallyChecksForUpdates = updater.automaticallyChecksForUpdates
    automaticallyDownloadsUpdates = updater.automaticallyDownloadsUpdates
  }
}

#Preview {
  UpdatesSettingsView()
}
