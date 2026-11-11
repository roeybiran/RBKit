import Foundation
import os
import Sparkle

// MARK: - SparkleManager

@MainActor
final class SparkleManager: NSObject {

  // MARK: Lifecycle

  init(
    hostBundle: Bundle = .main,
    applicationBundle: Bundle = .main,
  ) {
    self.hostBundle = hostBundle
    self.applicationBundle = applicationBundle
    super.init()
  }

  // MARK: Internal

  enum State {
    case idle
    case available(
      version: String,
      releaseNotes: String?,
      isInformationOnly: Bool,
      stage: UpdateStage,
    )
    case notFound(any Error)
    case failed(any Error)
    case downloadStarted(expectedContentLength: UInt64)
    case downloadProgressed(UInt64)
    case extractionStarted
    case extractionProgressed(Double)
    case readyToInstallAndRelaunch
    case installing(applicationTerminated: Bool)
    case installedAndRelaunched(Bool)
    case dismissed

    // MARK: Internal

    enum UpdateStage {
      case notDownloaded
      case downloaded
      case installing

      init(_ updateStage: SPUUserUpdateStage) {
        switch updateStage {
        case .notDownloaded:
          self = .notDownloaded
        case .downloaded:
          self = .downloaded
        case .installing:
          self = .installing
        @unknown default:
          self = .notDownloaded
        }
      }
    }

  }

  private(set) var state = State.idle {
    didSet {
      for continuation in streamContinuations.values {
        continuation.yield(state)
      }
    }
  }

  func start() -> AsyncStream<State> {
    AsyncStream { continuation in
      let id = UUID()
      streamContinuations[id] = continuation
      continuation.onTermination = { [weak self] _ in
        Task { @MainActor in
          self?.streamContinuations.removeValue(forKey: id)
        }
      }
      do {
        try updater.start()
      } catch {
        state = .failed(error)
      }
    }
  }

  func checkForUpdates() {
    updater.checkForUpdates()
  }

  func getAutomaticallyChecksForUpdates() -> Bool {
    updater.automaticallyChecksForUpdates
  }

  func setAutomaticallyChecksForUpdates(_ newValue: Bool) {
    updater.automaticallyChecksForUpdates = newValue
  }

  func getAutomaticallyDownloadsUpdates() -> Bool {
    updater.automaticallyDownloadsUpdates
  }

  func setAutomaticallyDownloadsUpdates(_ newValue: Bool) {
    updater.automaticallyDownloadsUpdates = newValue
  }

  func getLastUpdateCheckDate() -> Date? {
    updater.lastUpdateCheckDate
  }

  // MARK: Private

  private let logger = Logger(subsystem: "com.roeybiran.RBKitPrivate.SparkleExtras", category: "SparkleManager")

  /// The updater must reference this user driver, so it is created after init.
  private lazy var updater = SPUUpdater(
    hostBundle: hostBundle,
    applicationBundle: applicationBundle,
    userDriver: self,
    delegate: nil,
  )

  private let hostBundle: Bundle
  private let applicationBundle: Bundle
  private var streamContinuations = [UUID: AsyncStream<State>.Continuation]()

}

// MARK: SPUUserDriver

// https://sparkle-project.github.io/documentation/api-reference/Protocols/SPUUserDriver.html

extension SparkleManager: SPUUserDriver {
  func show(_: SPUUpdatePermissionRequest) async -> SUUpdatePermissionResponse {
    logger.debug("SPUUserDriver.show(_:)")
    return .init(
      automaticUpdateChecks: updater.automaticallyChecksForUpdates,
      automaticUpdateDownloading: updater.automaticallyDownloadsUpdates as NSNumber,
      sendSystemProfile: updater.sendsSystemProfile,
    )
  }

  func showUserInitiatedUpdateCheck(cancellation _: @escaping () -> Void) {
    logger.debug("SPUUserDriver.showUserInitiatedUpdateCheck(cancellation:)")
  }

  func showUpdateFound(
    with appcastItem: SUAppcastItem,
    state userUpdateState: SPUUserUpdateState,
  ) async -> SPUUserUpdateChoice {
    logger.debug(
      "SPUUserDriver.showUpdateFound(with:state:) version=\(appcastItem.displayVersionString, privacy: .public) stage=\(String(describing: userUpdateState.stage), privacy: .public)"
    )
    state = .available(
      version: appcastItem.displayVersionString,
      releaseNotes: appcastItem.itemDescription,
      isInformationOnly: appcastItem.isInformationOnlyUpdate,
      stage: .init(userUpdateState.stage),
    )
    return .dismiss
  }

  func showUpdateReleaseNotes(with _: SPUDownloadData) {
    logger.debug("SPUUserDriver.showUpdateReleaseNotes(with:)")
  }

  func showUpdateReleaseNotesFailedToDownloadWithError(_ error: any Error) {
    logger
      .debug(
        "SPUUserDriver.showUpdateReleaseNotesFailedToDownloadWithError(_:) error=\(error.localizedDescription, privacy: .public)"
      )
  }

  func showUpdateNotFoundWithError(_ error: any Error) async {
    logger.debug("SPUUserDriver.showUpdateNotFoundWithError(_:) error=\(error.localizedDescription, privacy: .public)")
    state = .notFound(error)
  }

  func showUpdaterError(_ error: any Error) async {
    logger.debug("SPUUserDriver.showUpdaterError(_:) error=\(error.localizedDescription, privacy: .public)")
    state = .failed(error)
  }

  func showDownloadInitiated(cancellation _: @escaping () -> Void) {
    logger.debug("SPUUserDriver.showDownloadInitiated(cancellation:)")
  }

  func showDownloadDidReceiveExpectedContentLength(_ expectedContentLength: UInt64) {
    logger
      .debug(
        "SPUUserDriver.showDownloadDidReceiveExpectedContentLength(_:) expectedContentLength=\(expectedContentLength, privacy: .public)"
      )
    state = .downloadStarted(expectedContentLength: expectedContentLength)
  }

  func showDownloadDidReceiveData(ofLength length: UInt64) {
    logger.debug("SPUUserDriver.showDownloadDidReceiveData(ofLength:) length=\(length, privacy: .public)")
    state = .downloadProgressed(length)
  }

  func showDownloadDidStartExtractingUpdate() {
    logger.debug("SPUUserDriver.showDownloadDidStartExtractingUpdate()")
    state = .extractionStarted
  }

  func showExtractionReceivedProgress(_ progressValue: Double) {
    logger.debug("SPUUserDriver.showExtractionReceivedProgress(_:) progressValue=\(progressValue, privacy: .public)")
    state = .extractionProgressed(max(0, min(progressValue, 1)))
  }

  func showReadyToInstallAndRelaunch() async -> SPUUserUpdateChoice {
    logger.debug("SPUUserDriver.showReadyToInstallAndRelaunch()")
    state = .readyToInstallAndRelaunch
    return .dismiss
  }

  func showInstallingUpdate(
    withApplicationTerminated applicationTerminated: Bool,
    retryTerminatingApplication _: @escaping () -> Void,
  ) {
    logger
      .debug(
        "SPUUserDriver.showInstallingUpdate(withApplicationTerminated:retryTerminatingApplication:) applicationTerminated=\(applicationTerminated, privacy: .public)"
      )
    state = .installing(applicationTerminated: applicationTerminated)
  }

  func showUpdateInstalledAndRelaunched(_ relaunched: Bool) async {
    logger.debug("SPUUserDriver.showUpdateInstalledAndRelaunched(_:) relaunched=\(relaunched, privacy: .public)")
    state = .installedAndRelaunched(relaunched)
  }

  func dismissUpdateInstallation() {
    logger.debug("SPUUserDriver.dismissUpdateInstallation()")
    state = .dismissed
  }
}
