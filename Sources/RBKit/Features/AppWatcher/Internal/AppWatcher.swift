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
    let state = State()

    let runningApplicationsTask = Task { @MainActor [self] in
      for await potentiallyUnsafeApps in nsWorkspaceClient
        .runningApplications(options: [.initial, .new])
        .compactMap(\.newValue)
      {
        var batchOfSafeApps = [NSRunningApplication]()
        for app in potentiallyUnsafeApps where isSafe(app) {
          batchOfSafeApps.append(app)
        }
        continuation.yield(.launched(batchOfSafeApps))

        for safeApp in batchOfSafeApps {
          debugLog(event: .launched, app: safeApp)
          state.observedApps.insert(safeApp)
          state.appTasks[safeApp]?.cancel()
          state.appTasks[safeApp] = Task { @MainActor [self] in
            do {
              try await observeRunningApplication(safeApp, continuation: continuation)
            } catch ObservationError.terminated {
              state.observedApps.remove(safeApp)
              state.appTasks[safeApp] = nil
            } catch is CancellationError {
            } catch {
              assertionFailure("Unexpected AppWatcher observation error: \(error)")
            }
          }
        }
      }
    }

    let frontmostApplicationTask = Task { @MainActor in
      for await change in nsWorkspaceClient.frontmostApplication(options: [.initial, .old, .new]) {
        if let deactivatedApp = change.oldValue ?? nil, state.observedApps.contains(deactivatedApp) {
          debugLog(event: .deactivated, app: deactivatedApp)
          continuation.yield(.deactivated(deactivatedApp))
        }

        if let activatedApp = change.newValue ?? nil, state.observedApps.contains(activatedApp) {
          debugLog(event: .activated, app: activatedApp)
          continuation.yield(.activated(activatedApp))
        }
      }
    }

    let menuBarOwningApplicationTask = Task { @MainActor in
      for await change in nsWorkspaceClient.menuBarOwningApplication(options: [.initial, .old, .new]) {
        if let disownedApp = change.oldValue ?? nil, state.observedApps.contains(disownedApp) {
          debugLog(event: .disownedMenuBar, app: disownedApp)
          continuation.yield(.disownedMenuBar(disownedApp))
        }

        if let owningApp = change.newValue ?? nil, state.observedApps.contains(owningApp) {
          debugLog(event: .ownedMenuBar, app: owningApp)
          continuation.yield(.ownedMenuBar(owningApp))
        }
      }
    }

    let completionTask = Task { @MainActor in
      await runningApplicationsTask.value
      await state.waitForAppTasks()
      await frontmostApplicationTask.value
      await menuBarOwningApplicationTask.value
      continuation.finish()
    }

    continuation.onTermination = { _ in
      completionTask.cancel()
      runningApplicationsTask.cancel()
      frontmostApplicationTask.cancel()
      menuBarOwningApplicationTask.cancel()
      Task { @MainActor in
        state.cancelAppTasks()
      }
    }

    return stream
  }

  // MARK: Private

  private enum ObservationError: Error {
    case terminated
  }

  @MainActor
  private final class State: Sendable {
    var observedApps = Set<NSRunningApplication>()
    var appTasks = [NSRunningApplication: Task<Void, Never>]()

    func cancelAppTasks() {
      for task in appTasks.values {
        task.cancel()
      }
      appTasks.removeAll()
    }

    func waitForAppTasks() async {
      for task in appTasks.values {
        await task.value
      }
      appTasks.removeAll()
    }
  }

  private func observeRunningApplication(
    _ app: NSRunningApplication,
    continuation: AsyncStream<AppWatcherEvent>.Continuation,
  ) async throws {
    @Dependency(\.nsRunningApplicationClient) var dependencyNSRunningApplicationClient
    let nsRunningApplicationClient = dependencyNSRunningApplicationClient
    let observerTasks = [
      Task { @MainActor in
        for await isFinishedLaunching in nsRunningApplicationClient
          .boolChanges(app, \.isFinishedLaunching, [.initial, .new])
          .compactMap(\.newValue)
          .filter(\.self)
        {
          assert(isFinishedLaunching)
          debugLog(event: .isFinishedLaunching(isFinishedLaunching), app: app)
          continuation.yield(.didFinishedLaunching(app))
        }
      },

      Task { @MainActor in
        for await activationPolicy in nsRunningApplicationClient
          .activationPolicyChanges(app, \.activationPolicy, [.new])
          .compactMap(\.newValue)
        {
          debugLog(event: .activationPolicy(activationPolicy), app: app)
          continuation.yield(.activationPolicyChanged(app))
        }
      },

      Task { @MainActor in
        for await isHidden in nsRunningApplicationClient
          .boolChanges(app, \.isHidden, [.new])
          .compactMap(\.newValue)
        {
          debugLog(event: .isHidden(isHidden), app: app)
          continuation.yield(isHidden ? .hidden(app) : .unhidden(app))
        }
      },

      Task { @MainActor in
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
      },
    ]
    let (completionStream, completionContinuation) = AsyncStream.makeStream(of: Result<Void, Error>.self)
    let completionTasks = observerTasks.map { observerTask in
      Task {
        do {
          try await observerTask.value
          completionContinuation.yield(.success(()))
        } catch {
          completionContinuation.yield(.failure(error))
        }
      }
    }

    defer {
      for observerTask in observerTasks {
        observerTask.cancel()
      }
      for completionTask in completionTasks {
        completionTask.cancel()
      }
      completionContinuation.finish()
    }

    var remainingObserverCount = observerTasks.count
    for await result in completionStream {
      remainingObserverCount -= 1
      switch result {
      case .success:
        if remainingObserverCount == 0 {
          return
        }

      case .failure(let error):
        throw error
      }
    }
  }

  private func isSafe(_ app: NSRunningApplication) -> Bool {
    @Dependency(\.sysctlClient) var sysctlClient
    if app == .current {
      return false
    }

    // https://github.com/lwouis/alt-tab-macos/pull/3554
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
