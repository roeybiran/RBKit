import Carbon
import RBKit
import Testing

@testable import RBKit

// MARK: - EventTapManagerTests

@Suite
@MainActor
struct `EventTapManager Tests` {

  @Test
  func `Creates event tap and run loop source when starting with events of interest`() async throws {
    let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }

    sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(sut.taps["test"]?.id == "TAP")
    #expect(sut.runLoopSources["test"]?.id == "RUN_LOOP_SOURCE")
  }

  @Test
  func `Does nothing when event tap creation fails`() async throws {
    let (cgEventMock, _, _, sut) = makeMockManager()
    cgEventMock._createEventTap = { _, _, _, _, _ in nil }

    sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(sut.taps["test"] == nil)
    #expect(sut.runLoopSources["test"] == nil)
  }

  @Test
  func `Invokes client callback when event handler is triggered`() async throws {
    let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    var clientCallbackCalls = 0

    sut.start(id: "test", eventsOfInterest: []) { _, _ in
      clientCallbackCalls += 1
      return nil
    }

    // Simulate callback through Box
    if let box = sut.boxes["test"] {
      let proxy = unsafeBitCast(0, to: CGEventTapProxy.self)
      _ = box.eventHandler(proxy, .flagsChanged, .init(keyboardEventSource: nil, virtualKey: 0, keyDown: true)!)
    }

    #expect(clientCallbackCalls == 1)
  }

  @Test
  func `Calls CGEventClient.createEventTap once with correct parameters`() async throws {
    await confirmation("CGEventClient.createEventTap called once with correct parameters") { createEventTapCalled in
      let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "TAP")
      let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

      cgEventMock._createEventTap = { tap, place, options, eventsOfInterest, userInfo in
        #expect(tap == .cgSessionEventTap)
        #expect(place == .headInsertEventTap)
        #expect(options == .defaultTap)
        let expectedMask = ([CGEventType.keyDown, .flagsChanged] + [.tapDisabledByTimeout, .tapDisabledByUserInput])
          .map { 1 << $0.rawValue }
          .reduce(CGEventMask(), |)
        #expect(eventsOfInterest == expectedMask)
        #expect(userInfo != nil)
        createEventTapCalled()
        return mockMachPort
      }
      cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }

      sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }
    }
  }

  @Test
  func `Calls CFMachPortClientProtocol.createRunLoopSource once with correct parameters`() async throws {
    await confirmation("CFMachPortClientProtocol.createRunLoopSource called once with correct parameters") { createRunLoopSourceCalled in
      let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "TAP")
      let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

      cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
      cfMachPortMock._createRunLoopSource = { port, order in
        #expect(port === mockMachPort)
        #expect(order == 0)
        createRunLoopSourceCalled()
        return mockRunLoopSource
      }

      sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }
    }
  }

  @Test
  func `Calls CFRunLoopClient.add once with correct parameters`() async throws {
    await confirmation("CFRunLoopClient.add called once with correct parameters") { addCalled in
      let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "TAP")
      let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

      cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
      cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
      cfRunLoopMock._add = { source, runLoop, mode in
        #expect(source === mockRunLoopSource)
        #expect(runLoop === CFRunLoopGetMain())
        #expect(mode == .commonModes)
        addCalled()
      }

      sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }
    }
  }

  @Test
  func `Does nothing when starting with duplicate ID`() async throws {
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

    // Set up first tap
    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfRunLoopMock._add = { (_: RunLoopSourceMock, _: CFRunLoop, _: CFRunLoopMode) in }

    sut.start(id: "test", eventsOfInterest: [.keyDown]) { _, _ in nil }

    // Verify first tap was created
    #expect(sut.taps["test"] != nil)

    // Track calls for second attempt
    var createEventTapCallCount = 0
    var createRunLoopSourceCallCount = 0
    var addCallCount = 0

    cgEventMock._createEventTap = { _, _, _, _, _ in
      createEventTapCallCount += 1
      return mockMachPort
    }
    cfMachPortMock._createRunLoopSource = { _, _ in
      createRunLoopSourceCallCount += 1
      return mockRunLoopSource
    }
    cfRunLoopMock._add = { (_: RunLoopSourceMock, _: CFRunLoop, _: CFRunLoopMode) in
      addCallCount += 1
    }

    // Attempt to start with same ID
    sut.start(id: "test", eventsOfInterest: [.flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    // Verify no dependencies were called for duplicate ID
    #expect(createEventTapCallCount == 0)
    #expect(createRunLoopSourceCallCount == 0)
    #expect(addCallCount == 0)

    // Verify original tap is still there
    #expect(sut.taps["test"] === mockMachPort)
  }

  @Test
  func `Calls CFRunLoopClient.remove once with correct parameters`() async throws {
    await confirmation("CFRunLoopClient.remove called once with correct parameters") { removeCalled in
      let (_, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "A")
      let mockRunLoopSource = RunLoopSourceMock(id: "B")
      sut.taps["test"] = mockMachPort
      sut.runLoopSources["test"] = mockRunLoopSource

      cfMachPortMock._invalidate = { (_: MachPortMock) in }
      cfRunLoopMock._remove = { source, runLoop, mode in
        #expect(source === mockRunLoopSource)
        #expect(runLoop === CFRunLoopGetMain())
        #expect(mode == .commonModes)
        removeCalled()
      }

      sut.stop(id: "test")
    }
  }

  @Test
  func `Calls CFMachPortClientProtocol.invalidate once with correct parameters`() async throws {
    await confirmation("CFMachPortClientProtocol.invalidate called once with correct parameters") { invalidateCalled in
      let (_, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "A")
      let mockRunLoopSource = RunLoopSourceMock(id: "B")
      sut.taps["test"] = mockMachPort
      sut.runLoopSources["test"] = mockRunLoopSource

      cfMachPortMock._invalidate = { machPort in
        #expect(machPort === mockMachPort)
        invalidateCalled()
      }
      cfRunLoopMock._remove = { (_: RunLoopSourceMock, _: CFRunLoop, _: CFRunLoopMode) in }

      sut.stop(id: "test")
    }
  }

  @Test
  func `Cleans up all internal state when stopping`() async throws {
    let (_, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "A")
    let mockRunLoopSource = RunLoopSourceMock(id: "B")
    sut.taps["test"] = mockMachPort
    sut.runLoopSources["test"] = mockRunLoopSource

    cfMachPortMock._invalidate = { (_: MachPortMock) in }
    cfRunLoopMock._remove = { (_: RunLoopSourceMock, _: CFRunLoop, _: CFRunLoopMode) in }

    sut.stop(id: "test")

    #expect(sut.taps["test"] == nil)
    #expect(sut.runLoopSources["test"] == nil)
    #expect(sut.boxes["test"] == nil)
  }

  @Test
  func `Calls CGEventClient.getEnabled once with correct parameters and returns result`() async throws {
    await confirmation("CGEventClient.getEnabled called once with correct parameters") { getEnabledCalled in
      let (cgEventMock, _, _, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "A")
      cgEventMock._getEnabled = { tap in
        #expect(tap === mockMachPort)
        getEnabledCalled()
        return true
      }
      sut.taps["test"] = mockMachPort

      let result = sut.getIsEnabled(id: "test")

      #expect(result == true)
    }
  }

  @Test
  func `Returns false when no event tap exists`() async throws {
    let (_, _, _, sut) = makeMockManager()

    let result = sut.getIsEnabled(id: "test")

    #expect(result == false)
  }

  @Test
  func `Calls CGEventClient.setEnabled once with correct parameters`() async throws {
    await confirmation("CGEventClient.setEnabled called once with correct parameters") { setEnabledCalled in
      let (cgEventMock, _, _, sut) = makeMockManager()
      let mockMachPort = MachPortMock(id: "F")
      sut.taps["test"] = mockMachPort

      cgEventMock._setEnabled = { tap, isEnabled in
        #expect(tap === mockMachPort)
        #expect(isEnabled == true)
        setEnabledCalled()
      }

      sut.setIsEnabled(id: "test", true)
    }
  }

  @Test
  func `Does nothing when no event tap exists`() async throws {
    let (cgEventMock, _, _, sut) = makeMockManager()

    var setEnabledCalled = false
    cgEventMock._setEnabled = { (_: MachPortMock, _: Bool) in setEnabledCalled = true }

    sut.setIsEnabled(id: "test", false)

    #expect(!setEnabledCalled)
  }
}

@MainActor
func makeMockManager() -> (
  cgEventMock: CGEventClientMock,
  cfMachPortMock: CFMachPortClientMock,
  cfRunLoopMock: CFRunLoopClientMock,
  manager: EventTapManager<CGEventClientMock, CFMachPortClientMock, CFRunLoopClientMock>
) {
  let cgEventMock = CGEventClientMock()
  let cfMachPortMock = CFMachPortClientMock()
  let cfRunLoopMock = CFRunLoopClientMock()
  let manager = RBKit.EventTapManager(
    cgEventClient: cgEventMock,
    cfMachPortClient: cfMachPortMock,
    cfRunLoopClient: cfRunLoopMock
  )
  return (cgEventMock, cfMachPortMock, cfRunLoopMock, manager)
}
