import AppKit
import ApplicationServices
import Dependencies
import RBKit
import Testing

@testable import RBKit

@Suite(.serialized)
@MainActor
struct `AppWatcher Tests` {
  @Test
  func `NSWorkspace observations: should observe correct key paths and NSKeyValueObservingOptions`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      var observeCalls: [(keyPath: String, options: NSKeyValueObservingOptions)] = []
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._addObserver = { _, keyPath, options, _ in
        observeCalls.append((keyPath: keyPath, options: options))
      }
      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await _ in SUT.events() { }
      }

      try? await Task.sleep(for: testSleepDuration)

      let expectedCalls = [
        (keyPath: #keyPath(NSWorkspace.runningApplications), options: NSKeyValueObservingOptions([.initial, .new])),
        (keyPath: #keyPath(NSWorkspace.frontmostApplication), options: NSKeyValueObservingOptions([.initial, .old, .new])),
      ]

      for (i, call) in expectedCalls.enumerated() {
        #expect(call.keyPath == observeCalls[i].keyPath)
        #expect(call.options == observeCalls[i].options)
      }

      #expect(observeCalls.count == 2)
    }
  }

  @Test
  func `NSWorkspace observations: with running applications changed, should emit launched event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      var collectedEvents: [AppWatcherEvent] = []

      let mockApp1 = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let mockApp2 = AppMock(_isFinishedLaunching: false, _processIdentifier: 1)
      let mockApps = [mockApp1, mockApp2]
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._frontmostApplication = mockApp1

      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      mockWorkspace._runningApplications = mockApps

      try? await Task.sleep(for: testSleepDuration)

      #expect(Set(SUT.appObservations.keys) == Set(mockApps))
      #expect(SUT.appObservations.keys.count == 2)

      for (_, value) in SUT.appObservations {
        #expect(value.count == 4)
      }

      let expectedEvents: [AppWatcherEvent] = [
        .launched(mockApps),
        .activated(mockApp1),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSWorkspace observations: with first app is current, should skip app`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let regularApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 1)
      let mockApps = [.current, regularApp]
      let mockWorkspace = NSWorkspace.Mock()
      let SUT = AppWatcher(workspace: mockWorkspace)

      var collectedEvents: [AppWatcherEvent] = []
      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      mockWorkspace._runningApplications = mockApps
      try? await Task.sleep(for: testSleepDuration)

      #expect(SUT.appObservations.keys.count == 1)
      #expect(SUT.appObservations[regularApp]?.count == 4)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([regularApp])
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSWorkspace observations: with first app is XPC, should skip app`() async throws {
    nonisolated(unsafe) var getProcessInfoCallCount = 0
    nonisolated(unsafe) var getProcessForPIDCallCount = 0

    await withDependencies { deps in
      deps.processesClient = ProcessesClient(
        getProcessInformation: { pid, info in
          getProcessInfoCallCount += 1
          if pid.pointee.highLongOfPSN == 0 {
            info.pointee.processType = NSHFSTypeCodeFromFileType("'XPC!'")
          } else {
            info.pointee.processType = NSHFSTypeCodeFromFileType("'APPL'")
          }
          return .zero
        },
        getProcessForPID: { pid, ptr in
          getProcessForPIDCallCount += 1
          if pid == 0 {
            ptr.pointee = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: 0)
          } else {
            ptr.pointee = ProcessSerialNumber(highLongOfPSN: 1, lowLongOfPSN: 1)
          }
          return noErr
        },
      )
      deps.sysctlClient = .nonZombie
    } operation: {
      let xpcApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let regularApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 1)
      let mockApps = [xpcApp, regularApp]
      let mockWorkspace = NSWorkspace.Mock()

      var collectedEvents: [AppWatcherEvent] = []
      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      mockWorkspace._runningApplications = mockApps

      try? await Task.sleep(for: testSleepDuration)

      #expect(SUT.appObservations.keys.count == 1)
      #expect(SUT.appObservations[regularApp]?.count == 4)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([regularApp])
      ]

      #expect(collectedEvents == expectedEvents)
      #expect(getProcessInfoCallCount == 2)
      #expect(getProcessForPIDCallCount == 2)
    }

  }

  @Test
  func `NSWorkspace observations: with Passwords app as XPC, should not skip app`() async throws {
    await withDependencies { deps in
      deps.processesClient = ProcessesClient(
        getProcessInformation: { _, info in
          // Both apps are XPC processes
          info.pointee.processType = NSHFSTypeCodeFromFileType("'XPC!'")
          return .zero
        },
        getProcessForPID: { pid, ptr in
          if pid == 0 {
            ptr.pointee = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: 0)
          } else {
            ptr.pointee = ProcessSerialNumber(highLongOfPSN: 1, lowLongOfPSN: 1)
          }
          return noErr
        },
      )
      deps.sysctlClient = .nonZombie
    } operation: {
      let passwordsApp = AppMock(_isFinishedLaunching: false, _bundleIdentifier: "com.apple.Passwords", _processIdentifier: 0)
      let regularXPCApp = AppMock(_isFinishedLaunching: false, _bundleIdentifier: "com.example.xpc", _processIdentifier: 1)
      let mockApps = [passwordsApp, regularXPCApp]
      let mockWorkspace = NSWorkspace.Mock()

      var collectedEvents: [AppWatcherEvent] = []
      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      mockWorkspace._runningApplications = mockApps

      try? await Task.sleep(for: testSleepDuration)

      // Passwords app should be observed despite being XPC
      #expect(SUT.appObservations.keys.contains(passwordsApp))
      #expect(SUT.appObservations[passwordsApp]?.count == 4)

      // Regular XPC app should not be observed
      #expect(!SUT.appObservations.keys.contains(regularXPCApp))

      let expectedEvents: [AppWatcherEvent] = [
        .launched([passwordsApp])
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSWorkspace observations: with first app is zombie, should skip app`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = SysctlClient(
        run: { mib, _, oldp, _, _, _ in
          // Mock sysctl behavior: return zombie status based on PID
          if let kinfo = oldp?.assumingMemoryBound(to: kinfo_proc.self) {
            if mib?[3] == 0 { // PID 0 is zombie
              kinfo.pointee.kp_proc.p_stat = CChar(SZOMB)
            } else { // PID 1 is not zombie
              kinfo.pointee.kp_proc.p_stat = CChar(SRUN)
            }
          }
          return 0
        }
      )
    } operation: {
      let zombieApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let regularApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 1)
      let mockApps = [zombieApp, regularApp]
      let mockWorkspace = NSWorkspace.Mock()
      var collectedEvents: [AppWatcherEvent] = []
      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      mockWorkspace._runningApplications = mockApps

      try? await Task.sleep(for: testSleepDuration)

      #expect(SUT.appObservations.keys.count == 1)
      #expect(SUT.appObservations[regularApp]?.count == 4)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([regularApp])
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSWorkspace.frontmostApplication observations: with frontmost application changed, should emit activated and deactivated events`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let mockApp2 = AppMock(_isFinishedLaunching: false, _processIdentifier: 1)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp, mockApp2]
      mockWorkspace._frontmostApplication = mockApp

      var collectedEvents: [AppWatcherEvent] = []
      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)
      mockWorkspace._frontmostApplication = mockApp2
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp, mockApp2]),
        .activated(mockApp),
        .deactivated(mockApp),
        .activated(mockApp2),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSWorkspace.frontmostApplication observations: with frontmost application nil, should not emit activated event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]
      mockWorkspace._frontmostApplication = mockApp

      let SUT = AppWatcher(workspace: mockWorkspace)
      var collectedEvents: [AppWatcherEvent] = []
      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)
      mockWorkspace._frontmostApplication = nil
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .activated(mockApp),
        .deactivated(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSWorkspace.frontmostApplication observations: with frontmost application not observed, should not emit activated event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let observedApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let nonObservedApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 1)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [observedApp]
      var collectedEvents: [AppWatcherEvent] = []

      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      mockWorkspace._frontmostApplication = nonObservedApp
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([observedApp])
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with initial isFinishedLaunching true, should emit didFinishedLaunching event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: true, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []

      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .didFinishedLaunching(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with initial isFinishedLaunching false, should not emit didFinishedLaunching event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []
      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp])
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with isFinishedLaunching changed to true, should emit didFinishedLaunching event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []

      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)
      mockApp._isFinishedLaunching = true
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .didFinishedLaunching(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with activation policy changed, should emit activationPolicyChanged event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _activationPolicy: .accessory, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []

      let SUT = AppWatcher(workspace: mockWorkspace)
      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)
      mockApp._activationPolicy = .regular
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .activationPolicyChanged(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with isHidden changed to true, should emit hidden event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _isHidden: false, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []
      let SUT = AppWatcher(workspace: mockWorkspace)
      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)
      mockApp._isHidden = true
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .hidden(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with isHidden changed to false, should emit unhidden event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isFinishedLaunching: false, _isHidden: true, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []

      let SUT = AppWatcher(workspace: mockWorkspace)
      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)
      mockApp._isHidden = false
      try? await Task.sleep(for: testSleepDuration)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .unhidden(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }

  @Test
  func `NSRunningApplication observations: with isTerminated changed to true, should emit terminated event`() async throws {
    await withDependencies { deps in
      deps.processesClient = .nonXPC
      deps.sysctlClient = .nonZombie
    } operation: {
      let mockApp = AppMock(_isTerminated: false, _isFinishedLaunching: false, _processIdentifier: 0)
      let mockWorkspace = NSWorkspace.Mock()
      mockWorkspace._runningApplications = [mockApp]

      var collectedEvents: [AppWatcherEvent] = []

      let SUT = AppWatcher(workspace: mockWorkspace)

      Task {
        for await event in SUT.events() {
          collectedEvents.append(event)
        }
      }

      try? await Task.sleep(for: testSleepDuration)

      // Verify app is being observed before termination
      #expect(SUT.appObservations.keys.contains(mockApp))
      #expect(SUT.appObservations[mockApp]?.count == 4)

      mockApp._isTerminated = true

      try? await Task.sleep(for: testSleepDuration)

      // Verify app observations are cleaned up after termination
      #expect(!SUT.appObservations.keys.contains(mockApp))
      #expect(SUT.appObservations[mockApp] == nil)

      let expectedEvents: [AppWatcherEvent] = [
        .launched([mockApp]),
        .terminated(mockApp),
      ]

      #expect(collectedEvents == expectedEvents)
    }
  }
}

extension AppWatcherEvent: CustomDebugStringConvertible {
  public var debugDescription: String {
    func appDescription(_ app: NSRunningApplication) -> String {
      "\(app.localizedName ?? "UNKNOWN") (pid: \(app.processIdentifier))"
    }

    switch self {
    case .launched(let apps):
      let appsDescription = apps.map { appDescription($0) }.joined(separator: ", ")
      return "launched [\(appsDescription)]"
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

private let testSleepDuration = Duration.seconds(0.02)
