import AppKit
import Dependencies
import DependenciesMacros
import Foundation
import RBKit

// https://developer.apple.com/documentation/foundation/nskeyvalueobservedchange/newvalue
// "newValue and oldValue will only be non-nil if .new/.old is passed to observe(). In general, get the most up to date value by accessing it directly on the observed object instead."
// https://stackoverflow.com/questions/56427889/kvo-swift-newvalue-is-always-nil

@MainActor
final class AppWatcher {

  // MARK: Lifecycle

  init(workspace: NSWorkspace) {
    self.workspace = workspace
  }

  // MARK: Internal

  var appObservations = [NSRunningApplication: [NSKeyValueObservation]]()

  func events() -> AsyncStream<AppWatcherEvent> {
    let (stream, continuation) = AsyncStream.makeStream(of: AppWatcherEvent.self)

    let runningApplicationsObservation = workspace.observe(\.runningApplications, options: [
      .initial,
      .new,
    ]) { [weak self, sysctlClient] _, change in
      guard let self else { assertionFailure()
        return
      }
      guard let unsafeApps = change.newValue else { assert(change.kind == .removal || change.kind == .replacement)
        return
      }

      var safeApps = [NSRunningApplication]()

      for unsafeApp in unsafeApps {
        let pid = unsafeApp.processIdentifier

        if unsafeApp == .current {
          continue
        }

        // Password is a special case of a process reported as "XPC" (misconfigured bundle perhaps) that has GUI
        // See https://github.com/lwouis/alt-tab-macos/issues/3545
        // See https://github.com/lwouis/alt-tab-macos/blob/e9e732756e140a080b0ed984af89051d447653b5/src/logic/Applications.swift#L104
        let isPasswords = unsafeApp.bundleIdentifier == "com.apple.Passwords"
        if let nsFileType = Self.getNSFileType(pid: pid), !isPasswords, nsFileType == "'XPC!'" {
          debugLog(event: .skippingXPC(nsFileType), app: unsafeApp)
          continue
        }

        if sysctlClient.isZombie(pid: pid) {
          debugLog(event: .skippingZombie, app: unsafeApp)
          continue
        }

        safeApps.append(unsafeApp)
      }

      continuation.yield(.launched(safeApps))

      for safeApp in safeApps {
        debugLog(event: .launched, app: safeApp)

        let isFinishedLaunchingObservation = safeApp.observe(\.isFinishedLaunching, options: [.initial, .new]) { app, change in
          guard app.isFinishedLaunching else { return }
          assert(change.newValue != nil)
          debugLog(event: .isFinishedLaunching(app.isFinishedLaunching), app: app)
          continuation.yield(.didFinishedLaunching(app))
        }

        let activationPolicyObservation = safeApp.observe(\.activationPolicy, options: [.new]) { app, _ in
          debugLog(event: .activationPolicy(app.activationPolicy), app: app)
          continuation.yield(.activationPolicyChanged(app))
        }

        let isHiddenObservation = safeApp.observe(\.isHidden, options: [.new]) { app, change in
          assert(change.newValue != nil)
          debugLog(event: .isHidden(app.isHidden), app: app)
          continuation.yield(app.isHidden ? .hidden(app) : .unhidden(app))
        }

        let isTerminatedObservation = safeApp.observe(\.isTerminated, options: [.new]) { app, change in
          assert(change.newValue == true)
          debugLog(event: .terminated(app.isTerminated), app: app)
          continuation.yield(.terminated(app))
          Task { @MainActor [weak self] in
            guard let self else { return assertionFailure() }
            guard let existingObservations = appObservations.removeValue(forKey: app) else { return }
            for observation in existingObservations {
              observation.invalidate()
            }
          }
        }

        Task { @MainActor [weak self] in
          guard let self else { return assertionFailure() }
          appObservations[safeApp, default: []] = [
            isFinishedLaunchingObservation,
            activationPolicyObservation,
            isHiddenObservation,
            isTerminatedObservation,
          ]
        }
      }
    }

    //  much more reliable than observing "\.isActive" individually on the app
    let frontmostApplicationObservation = workspace.observe(\.frontmostApplication, options: [
      .initial,
      .old,
      .new,
    ]) { [weak self] workspace, change in
      let frontmostApp = workspace.frontmostApplication
      Task { @MainActor [weak self] in
        guard let self else { return }
        if let oldValue = change.oldValue, let deactivatedApp = oldValue {
          if appObservations[deactivatedApp] == nil { return }
          continuation.yield(.deactivated(deactivatedApp))
        }

        guard let frontmostApp else { return }
        debugLog(event: .activated, app: frontmostApp)
        if appObservations[frontmostApp] == nil { return }
        continuation.yield(.activated(frontmostApp))
      }
    }

    continuation.onTermination = { _ in
      runningApplicationsObservation.invalidate()
      frontmostApplicationObservation.invalidate()
    }

    return stream
  }

  // MARK: Private

  @Dependency(\.sysctlClient) private var sysctlClient

  private let workspace: NSWorkspace

  /// "these private APIs are more reliable than Bundle.init? as it can return nil (e.g. for com.apple.dock.etci)"
  /// https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/logic/Applications.swift#L115
  private static nonisolated func getNSFileType(pid: pid_t) -> String? {
    @Dependency(\.processesClient) var processesClient
    var psn = ProcessSerialNumber()
    _ = processesClient.getProcessForPID(pid, &psn)
    var info = ProcessInfoRec()
    _ = processesClient.getProcessInformation(&psn, &info)
    // https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/api-wrappers/HelperExtensions.swift#L174
    let nsFileType = NSFileTypeForHFSTypeCode(info.processType)

    assert({
      if let nsFileType, nsFileType.contains("XPC") {
        nsFileType == "'XPC!'"
      } else {
        true
      }
    }())

    return nsFileType
  }

}
