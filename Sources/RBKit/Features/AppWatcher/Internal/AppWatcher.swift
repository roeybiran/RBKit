import AppKit
import Dependencies
import DependenciesMacros
import Foundation

/// https://developer.apple.com/documentation/foundation/nskeyvalueobservedchange/newvalue
/// "newValue and oldValue will only be non-nil if .new/.old is passed to observe(). In general, get the most up to date value by accessing it directly on the observed object instead."
/// https://stackoverflow.com/questions/56427889/kvo-swift-newvalue-is-always-nil
@MainActor
struct AppWatcher {

  // MARK: Internal

  func events() -> AsyncStream<AppWatcherEvent> {
    @Dependency(\.nsWorkspaceClient) var nsWorkspaceClient
    let (stream, continuation) = AsyncStream.makeStream(of: AppWatcherEvent.self)

    let task = Task { [self] in
      var observedApps = Set<NSRunningApplication>()

      await withTaskGroup(of: Void.self) { workspaceTaskGroup in
        // MARK: - Running Applications
        workspaceTaskGroup.addTask { @MainActor [self] in
          await withTaskGroup(of: Void.self) { appTaskGroup in
            for await potentiallyUnsafeApps in nsWorkspaceClient
              .runningApplications(options: [.initial, .new])
              .compactMap(\.newValue)
            {
              let batchOfSafeApps = potentiallyUnsafeApps.filter { isSafe($0) }
              continuation.yield(.launched(batchOfSafeApps))

              for safeApp in batchOfSafeApps {
                debugLog(event: .launched, app: safeApp)
                observedApps.insert(safeApp)
                appTaskGroup.addTask { @MainActor [self] in
                  do {
                    try await observeRunningApplication(safeApp, continuation: continuation)
                  } catch ObservationError.terminated {
                    observedApps.remove(safeApp)
                  } catch is CancellationError {
                  } catch {
                    assertionFailure("Unexpected AppWatcher observation error: \(error)")
                  }
                }
              }
            }
          }
        }

        // MARK: - Frontmost Application
        workspaceTaskGroup.addTask { @MainActor in
          for await change in nsWorkspaceClient.frontmostApplication(options: [.initial, .old, .new]) {
            if let deactivatedApp = change.oldValue ?? nil, observedApps.contains(deactivatedApp) {
              debugLog(event: .deactivated, app: deactivatedApp)
              continuation.yield(.deactivated(deactivatedApp))
            }

            if let activatedApp = change.newValue ?? nil, observedApps.contains(activatedApp) {
              debugLog(event: .activated, app: activatedApp)
              continuation.yield(.activated(activatedApp))
            }
          }
        }

        // MARK: - Menu Bar Owning Application
        workspaceTaskGroup.addTask { @MainActor in
          for await change in nsWorkspaceClient.menuBarOwningApplication(options: [.initial, .old, .new]) {
            if let disownedApp = change.oldValue ?? nil, observedApps.contains(disownedApp) {
              debugLog(event: .disownedMenuBar, app: disownedApp)
              continuation.yield(.disownedMenuBar(disownedApp))
            }

            if let owningApp = change.newValue ?? nil, observedApps.contains(owningApp) {
              debugLog(event: .ownedMenuBar, app: owningApp)
              continuation.yield(.ownedMenuBar(owningApp))
            }
          }
        }
      }

      continuation.finish()
    }

    continuation.onTermination = { _ in
      task.cancel()
    }

    return stream
  }

  // MARK: Private

  private enum ObservationError: Error {
    case terminated
  }

  private func observeRunningApplication(
    _ app: NSRunningApplication,
    continuation: AsyncStream<AppWatcherEvent>.Continuation,
  ) async throws {
    @Dependency(\.nsRunningApplicationClient) var nsRunningApplicationClient
    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
      taskGroup.addTask { @MainActor in
        for await isFinishedLaunching in nsRunningApplicationClient
          .boolChanges(app, \.isFinishedLaunching, [.initial, .new])
          .compactMap(\.newValue)
          .filter(\.self)
        {
          assert(isFinishedLaunching)
          debugLog(event: .isFinishedLaunching(isFinishedLaunching), app: app)
          continuation.yield(.didFinishedLaunching(app))
        }
      }

      taskGroup.addTask { @MainActor in
        for await activationPolicy in nsRunningApplicationClient
          .activationPolicyChanges(app, \.activationPolicy, [.new])
          .compactMap(\.newValue)
        {
          debugLog(event: .activationPolicy(activationPolicy), app: app)
          continuation.yield(.activationPolicyChanged(app))
        }
      }

      taskGroup.addTask { @MainActor in
        for await isHidden in nsRunningApplicationClient
          .boolChanges(app, \.isHidden, [.new])
          .compactMap(\.newValue)
        {
          debugLog(event: .isHidden(isHidden), app: app)
          continuation.yield(isHidden ? .hidden(app) : .unhidden(app))
        }
      }

      // Throwing here cancels the sibling observers for this app.
      taskGroup.addTask { @MainActor in
        for await isTerminated in nsRunningApplicationClient
          .boolChanges(app, \.isTerminated, [.new])
          .compactMap(\.newValue)
          .filter(\.self)
        {
          assert(isTerminated)
          debugLog(event: .terminated(isTerminated), app: app)
          continuation.yield(.terminated(app))
          throw ObservationError.terminated
        }
      }

      while try await taskGroup.next() != nil { }
    }
  }

  private func isSafe(_ app: NSRunningApplication) -> Bool {
    @Dependency(\.sysctlClient) var sysctlClient
    if app == .current {
      return false
    }

    let isPasswords = app.bundleIdentifier == "com.apple.Passwords"
    if let nsFileType = getNSFileType(pid: app.processIdentifier), !isPasswords, nsFileType == "'XPC!'" {
      debugLog(event: .skippingXPC(nsFileType), app: app)
      return false
    }

    if sysctlClient.isZombie(pid: app.processIdentifier) {
      debugLog(event: .skippingZombie, app: app)
      return false
    }

    return true
  }

  /// "these private APIs are more reliable than Bundle.init? as it can return nil (e.g. for com.apple.dock.etci)"
  /// https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/logic/Applications.swift#L115
  private func getNSFileType(pid: pid_t) -> String? {
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
