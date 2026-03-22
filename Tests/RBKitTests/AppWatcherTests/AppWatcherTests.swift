import AppKit
import ApplicationServices
import Dependencies
import RBKit
import Testing

@testable import RBKit

@Suite(.serialized)
@MainActor
struct AppWatcherTests {
  @Test
  func `events should filter current XPC and zombie apps but keep Passwords`() async {
    let passwords = AppMock(
      _bundleIdentifier: "com.apple.Passwords",
      _processIdentifier: 1
    )
    let xpc = AppMock(
      _bundleIdentifier: "com.example.xpc",
      _processIdentifier: 2
    )
    let zombie = AppMock(_processIdentifier: 3)
    let regular = AppMock(_processIdentifier: 4)

    let actualEvents = await withDependencies { deps in
      deps.processesClient = ProcessesClient(
        getProcessInformation: { pid, info in
          switch pid.pointee.highLongOfPSN {
          case 1, 2:
            info.pointee.processType = NSHFSTypeCodeFromFileType("'XPC!'")
          default:
            info.pointee.processType = NSHFSTypeCodeFromFileType("'APPL'")
          }
          return .zero
        },
        getProcessForPID: { pid, ptr in
          ptr.pointee = ProcessSerialNumber(
            highLongOfPSN: UInt32(pid),
            lowLongOfPSN: UInt32(pid)
          )
          return noErr
        },
      )
      deps.sysctlClient = SysctlClient(
        run: { mib, _, oldp, _, _, _ in
          if let kinfo = oldp?.assumingMemoryBound(to: kinfo_proc.self) {
            kinfo.pointee.kp_proc.p_stat = mib?[3] == 3 ? CChar(SZOMB) : CChar(SRUN)
          }
          return 0
        }
      )
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([.init(newValue: [.current, passwords, xpc, zombie, regular])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in .finished }
      deps.nsRunningApplicationClient.boolChanges = { _, _, _ in .finished }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, _ in .finished }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([passwords, regular])])
  }

  @Test
  func `events should start per app observation for every running applications change`() async {
    let app1 = AppMock(_processIdentifier: 0)
    let app2 = AppMock(_processIdentifier: 1)
    var boolObservationCalls = [(pid: pid_t, label: String, options: NSKeyValueObservingOptions)]()
    var activationPolicyObservationCalls = [(pid: pid_t, options: NSKeyValueObservingOptions)]()

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([
          .init(newValue: [app1, app2]),
          .init(newValue: [app1, app2]),
        ])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in .finished }
      deps.nsRunningApplicationClient.boolChanges = { app, keyPath, options in
        let label =
          if keyPath == \.isFinishedLaunching {
            #keyPath(NSRunningApplication.isFinishedLaunching)
          } else if keyPath == \.isHidden {
            #keyPath(NSRunningApplication.isHidden)
          } else {
            #keyPath(NSRunningApplication.isTerminated)
          }
        boolObservationCalls.append((app.processIdentifier, label, options))
        return .finished
      }
      deps.nsRunningApplicationClient.activationPolicyChanges = { app, _, options in
        activationPolicyObservationCalls.append((app.processIdentifier, options))
        return .finished
      }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([app1, app2]), .launched([app1, app2])])
    #expect(
      boolObservationCalls.filter {
        $0.pid == app1.processIdentifier
          && $0.label == #keyPath(NSRunningApplication.isFinishedLaunching)
          && $0.options == [.initial, .new]
      }.count == 2
    )
    #expect(
      boolObservationCalls.filter {
        $0.pid == app1.processIdentifier
          && $0.label == #keyPath(NSRunningApplication.isHidden)
          && $0.options == [.new]
      }.count == 2
    )
    #expect(
      boolObservationCalls.filter {
        $0.pid == app1.processIdentifier
          && $0.label == #keyPath(NSRunningApplication.isTerminated)
          && $0.options == [.new]
      }.count == 2
    )
    #expect(
      boolObservationCalls.filter {
        $0.pid == app2.processIdentifier
          && $0.label == #keyPath(NSRunningApplication.isFinishedLaunching)
          && $0.options == [.initial, .new]
      }.count == 2
    )
    #expect(
      boolObservationCalls.filter {
        $0.pid == app2.processIdentifier
          && $0.label == #keyPath(NSRunningApplication.isHidden)
          && $0.options == [.new]
      }.count == 2
    )
    #expect(
      boolObservationCalls.filter {
        $0.pid == app2.processIdentifier
          && $0.label == #keyPath(NSRunningApplication.isTerminated)
          && $0.options == [.new]
      }.count == 2
    )
    #expect(
      activationPolicyObservationCalls.filter {
        $0.pid == app1.processIdentifier && $0.options == [.new]
      }.count == 2
    )
    #expect(
      activationPolicyObservationCalls.filter {
        $0.pid == app2.processIdentifier && $0.options == [.new]
      }.count == 2
    )
  }

  @Test
  func `events should emit frontmost transitions only for observed apps`() async {
    let app1 = AppMock(_processIdentifier: 0)
    let app2 = AppMock(_processIdentifier: 1)
    let unobservedApp = AppMock(_processIdentifier: 2)

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([.init(newValue: [app1, app2])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in
        AsyncStream { continuation in
          Task { @MainActor in
            await Task.yield()
            continuation.yield(.init(oldValue: app1, newValue: app2))
            continuation.yield(.init(oldValue: app2, newValue: .some(nil)))
            continuation.yield(.init(newValue: unobservedApp))
            continuation.finish()
          }
        }
      }
      deps.nsRunningApplicationClient.boolChanges = { _, _, _ in .finished }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, _ in .finished }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(
      actualEvents == [
        .launched([app1, app2]),
        .deactivated(app1),
        .activated(app2),
        .deactivated(app2),
      ]
    )
  }

  @Test
  func `events should emit didFinishedLaunching`() async {
    let app = AppMock(_isFinishedLaunching: true, _processIdentifier: 0)

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([.init(newValue: [app])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in .finished }
      deps.nsRunningApplicationClient.boolChanges = { _, keyPath, _ in
        if keyPath == \.isFinishedLaunching {
          return stream([.init(newValue: true)])
        }
        return .finished
      }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, _ in .finished }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([app]), .didFinishedLaunching(app)])
  }

  @Test
  func `events should emit activationPolicyChanged`() async {
    let app = AppMock(_activationPolicy: .regular, _processIdentifier: 0)

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([.init(newValue: [app])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in .finished }
      deps.nsRunningApplicationClient.boolChanges = { _, _, _ in .finished }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, _ in
        stream([.init(newValue: .regular)])
      }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([app]), .activationPolicyChanged(app)])
  }

  @Test
  func `events should emit hidden and unhidden`() async {
    let app = AppMock(_isHidden: false, _processIdentifier: 0)

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([.init(newValue: [app])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in .finished }
      deps.nsRunningApplicationClient.boolChanges = { app, keyPath, _ in
        if keyPath == \.isHidden {
          guard let app = app as? AppMock else {
            return .finished
          }

          return AsyncStream { continuation in
            app._isHidden = true
            continuation.yield(.init(newValue: true))
            Task { @MainActor in
              await Task.yield()
              app._isHidden = false
              continuation.yield(.init(newValue: false))
              continuation.finish()
            }
          }
        }
        return .finished
      }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, _ in .finished }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([app]), .hidden(app), .unhidden(app)])
  }

  @Test
  func `events should emit terminated`() async {
    let app = AppMock(_isTerminated: true, _processIdentifier: 0)

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { _ in
        stream([.init(newValue: [app])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { _ in .finished }
      deps.nsRunningApplicationClient.boolChanges = { _, keyPath, _ in
        if keyPath == \.isTerminated {
          return stream([.init(newValue: true)])
        }
        return .finished
      }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, _ in .finished }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([app]), .terminated(app)])
  }

  @Test
  func `events glue code should request the expected observation streams`() async {
    let app = AppMock(_processIdentifier: 0)
    var runningApplicationsOptions = [NSKeyValueObservingOptions]()
    var frontmostApplicationOptions = [NSKeyValueObservingOptions]()
    var boolObservationCalls = [(label: String, options: NSKeyValueObservingOptions)]()
    var activationPolicyObservationCalls = [NSKeyValueObservingOptions]()

    let actualEvents = await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
      deps.nsWorkspaceClient.runningApplicationsChanges = { options in
        runningApplicationsOptions.append(options)
        return stream([.init(newValue: [app])])
      }
      deps.nsWorkspaceClient.frontmostApplicationChanges = { options in
        frontmostApplicationOptions.append(options)
        return stream([])
      }
      deps.nsRunningApplicationClient.boolChanges = { _, keyPath, options in
        let label =
          if keyPath == \.isFinishedLaunching {
            #keyPath(NSRunningApplication.isFinishedLaunching)
          } else if keyPath == \.isHidden {
            #keyPath(NSRunningApplication.isHidden)
          } else {
            #keyPath(NSRunningApplication.isTerminated)
          }
        boolObservationCalls.append((label, options))
        return .finished
      }
      deps.nsRunningApplicationClient.activationPolicyChanges = { _, _, options in
        activationPolicyObservationCalls.append(options)
        return .finished
      }
    } operation: {
      let sut = AppWatcher()
      return await collectEvents(from: sut.events())
    }

    #expect(actualEvents == [.launched([app])])
    #expect(runningApplicationsOptions == [[.initial, .new]])
    #expect(frontmostApplicationOptions == [[.initial, .old, .new]])
    #expect(
      boolObservationCalls.filter {
        $0.label == #keyPath(NSRunningApplication.isFinishedLaunching) && $0.options == [.initial, .new]
      }.count == 1
    )
    #expect(
      boolObservationCalls.filter {
        $0.label == #keyPath(NSRunningApplication.isHidden) && $0.options == [.new]
      }.count == 1
    )
    #expect(
      boolObservationCalls.filter {
        $0.label == #keyPath(NSRunningApplication.isTerminated) && $0.options == [.new]
      }.count == 1
    )
    #expect(activationPolicyObservationCalls == [[.new]])
  }
}

extension AppWatcherEvent: CustomDebugStringConvertible {
  public var debugDescription: String {
    func appDescription(_ app: NSRunningApplication) -> String {
      "\(app.localizedName ?? "UNKNOWN") (pid: \(app.processIdentifier))"
    }

    switch self {
    case .launched(let apps):
      return "launched [\(apps.map(appDescription).joined(separator: ", "))]"
    case .didFinishedLaunching(let app):
      return "didFinishedLaunching \(appDescription(app))"
    case .activated(let app):
      return "activated \(appDescription(app))"
    case .deactivated(let app):
      return "deactivated \(appDescription(app))"
    case .terminated(let app):
      return "terminated \(appDescription(app))"
    case .hidden(let app):
      return "hidden \(appDescription(app))"
    case .unhidden(let app):
      return "unhidden \(appDescription(app))"
    case .activationPolicyChanged(let app):
      return "activationPolicyChanged \(appDescription(app))"
    }
  }
}

private func collectEvents(from stream: AsyncStream<AppWatcherEvent>) async -> [AppWatcherEvent] {
  var events = [AppWatcherEvent]()

  for await event in stream {
    events.append(event)
  }

  return events
}

private func stream<Element: Sendable>(_ elements: [Element]) -> AsyncStream<Element> {
  AsyncStream { continuation in
    for element in elements {
      continuation.yield(element)
    }
    continuation.finish()
  }
}
