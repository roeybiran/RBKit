import SwiftUI

// MARK: - UpdatesSettingsViewV2

@MainActor
public struct UpdatesSettingsViewV2: View {

  // MARK: Lifecycle

  public init(label: String = "Software Updates:") {
    self.label = label
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      LabeledContent(label) {
        Text(viewModel.title)
      }

      LabeledContent("Current Version:") {
        Text(viewModel.currentVersion)
      }

      if let lastUpdateCheckDate = viewModel.lastUpdateCheckDate {
        LabeledContent("Last Checked:") {
          Text(lastUpdateCheckDate.formatted(date: .abbreviated, time: .shortened))
        }
      }

      if let releaseNotes = viewModel.releaseNotes {
        Text(releaseNotes)
          .font(.footnote)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }

      if !viewModel.isProgressBarHidden {
        VStack(alignment: .leading, spacing: 6) {
          if viewModel.isProgressIndeterminate {
            ProgressView()
              .controlSize(.small)
          } else if let progress = viewModel.progress {
            ProgressView(value: progress)
              .controlSize(.small)
          }
        }
      }

      Button(viewModel.buttonText.rawValue) {
        viewModel.buttonTapped()
      }
      .disabled(viewModel.isPrimaryButtonDisabled)

      Divider()

      Toggle(
        "Automatically check for updates",
        isOn: Binding(
          get: { viewModel.automaticallyChecksForUpdates },
          set: { viewModel.setAutomaticallyChecksForUpdates($0) },
        ),
      )

      Toggle(
        "Automatically download updates",
        isOn: Binding(
          get: { viewModel.automaticallyDownloadsUpdates },
          set: { viewModel.setAutomaticallyDownloadsUpdates($0) },
        ),
      )
      .disabled(!viewModel.automaticallyChecksForUpdates)
    }
  }

  // MARK: Internal

  let label: String

  // MARK: Private

  @StateObject private var viewModel = UpdateSettingsViewModel()
}

#Preview {
  UpdatesSettingsViewV2().padding()
}
