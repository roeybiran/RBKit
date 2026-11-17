import SwiftUI

// MARK: - UpdatesSettingsViewV2

/// Rows for a settings `Form`: the update status, a check button, and the automatic-update toggles.
@MainActor
public struct UpdatesSettingsViewV2: View {

  // MARK: Lifecycle

  public init(label: String = "Software updates") {
    self.label = label
  }

  // MARK: Public

  public var body: some View {
    LabeledContent(label) {
      Text(viewModel.title)
    }

    LabeledContent("Current version") {
      Text(viewModel.currentVersion)
    }

    if let lastUpdateCheckDate = viewModel.lastUpdateCheckDate {
      LabeledContent("Last checked") {
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
      if viewModel.isProgressIndeterminate {
        ProgressView()
          .controlSize(.small)
      } else if let progress = viewModel.progress {
        ProgressView(value: progress)
          .controlSize(.small)
      }
    }

    Button(viewModel.buttonText.rawValue) {
      viewModel.buttonTapped()
    }
    .disabled(viewModel.isPrimaryButtonDisabled)

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

  // MARK: Internal

  let label: String

  // MARK: Private

  @StateObject private var viewModel = UpdateSettingsViewModel()
}

#Preview {
  Form {
    UpdatesSettingsViewV2()
  }
  .formStyle(.grouped)
}
