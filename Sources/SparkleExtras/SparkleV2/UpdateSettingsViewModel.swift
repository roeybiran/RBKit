import Combine
import Dependencies
import Foundation

@MainActor
final class UpdateSettingsViewModel: ObservableObject {

  // MARK: Lifecycle

  init(
    hostBundle: Bundle = .main
  ) {
    self.hostBundle = hostBundle
    syncFromSparkleManager(state: state)
    updatesObservationTask = Task { @MainActor [weak self] in
      guard let self else { return }
      for await state in sparkleManagerClient.start() {
        syncFromSparkleManager(state: state)
      }
    }
  }

  deinit {
    updatesObservationTask?.cancel()
  }

  // MARK: Internal

  enum ButtonText: String {
    case check = "Check"
    case cancel = "Cancel"
    case download = "Download"
    case installAndRelaunch = "Install and Relaunch"
  }

  @Published private(set) var title = ""
  @Published private(set) var releaseNotes: String?
  @Published private(set) var progress: Double?
  @Published private(set) var buttonText = ButtonText.check
  @Published private(set) var currentVersion = "Unknown"
  @Published private(set) var lastUpdateCheckDate: Date?
  @Published private(set) var automaticallyChecksForUpdates = false
  @Published private(set) var automaticallyDownloadsUpdates = false
  @Published private(set) var isProgressBarHidden = true
  @Published private(set) var isProgressIndeterminate = false
  @Published private(set) var isPrimaryButtonDisabled = false

  func buttonTapped() {
    switch state {
    case .available, .readyToInstallAndRelaunch, .downloadStarted, .downloadProgressed:
      break
    default:
      sparkleManagerClient.checkForUpdates()
    }
    syncFromSparkleManager(state: state)
  }

  func setAutomaticallyChecksForUpdates(_ newValue: Bool) {
    sparkleManagerClient.setAutomaticallyChecksForUpdates(newValue)
    syncFromSparkleManager(state: state)
  }

  func setAutomaticallyDownloadsUpdates(_ newValue: Bool) {
    sparkleManagerClient.setAutomaticallyDownloadsUpdates(newValue)
    syncFromSparkleManager(state: state)
  }

  // MARK: Private

  private let hostBundle: Bundle
  private var state = SparkleManager.State.idle
  private var updatesObservationTask: Task<Void, Never>?
  @Dependency(\.sparkleManagerClient) private var sparkleManagerClient

  private func syncFromSparkleManager(state: SparkleManager.State) {
    self.state = state

    let shortVersion = hostBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let buildVersion = hostBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    switch (shortVersion, buildVersion) {
    case (let shortVersion?, let buildVersion?) where shortVersion != buildVersion:
      currentVersion = "\(shortVersion) (\(buildVersion))"
    case (let shortVersion?, _):
      currentVersion = shortVersion
    case (_, let buildVersion?):
      currentVersion = buildVersion
    default:
      currentVersion = "Unknown"
    }

    lastUpdateCheckDate = sparkleManagerClient.getLastUpdateCheckDate()
    automaticallyChecksForUpdates = sparkleManagerClient.getAutomaticallyChecksForUpdates()
    automaticallyDownloadsUpdates = sparkleManagerClient.getAutomaticallyDownloadsUpdates()
    switch state {
    case .available(_, let releaseNotes, _, _):
      self.releaseNotes = releaseNotes
    case .downloadStarted, .downloadProgressed, .extractionStarted, .extractionProgressed, .readyToInstallAndRelaunch,
         .installing:
      break
    default:
      releaseNotes = nil
    }

    switch state {
    case .downloadStarted, .downloadProgressed, .extractionStarted, .extractionProgressed, .installing:
      isProgressBarHidden = false
    default:
      isProgressBarHidden = true
    }

    switch state {
    case .downloadStarted, .downloadProgressed, .extractionStarted, .installing:
      isProgressIndeterminate = true
    default:
      isProgressIndeterminate = false
    }

    if isProgressBarHidden || isProgressIndeterminate {
      progress = nil
    } else if case .extractionProgressed(let extractionProgress) = state {
      progress = extractionProgress
    } else {
      progress = nil
    }

    switch state {
    case .idle, .dismissed, .failed, .installedAndRelaunched:
      title = ""
      buttonText = .check
      isPrimaryButtonDisabled = false

    case .available(let version, _, _, let stage):
      title = "A new version is available — \(version), you have \(currentVersion)"
      buttonText = stage == .notDownloaded ? .download : .installAndRelaunch
      isPrimaryButtonDisabled = true

    case .notFound:
      title = "You have the latest version — \(currentVersion)"
      buttonText = .check
      isPrimaryButtonDisabled = false

    case .downloadStarted, .downloadProgressed, .extractionStarted, .extractionProgressed:
      title = "Downloading..."
      buttonText = .check
      isPrimaryButtonDisabled = true

    case .readyToInstallAndRelaunch:
      title = "Installing..."
      buttonText = .installAndRelaunch
      isPrimaryButtonDisabled = true

    case .installing:
      title = "Installing..."
      buttonText = .check
      isPrimaryButtonDisabled = true
    }
  }
}
