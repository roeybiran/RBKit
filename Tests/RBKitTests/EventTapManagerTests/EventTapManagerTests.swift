import Carbon
import RBKit
import Testing

@testable import RBKit

// MARK: - EventTapManagerTests

@MainActor
struct EventTapManagerTests {

  @Test
  func `Creates event tap and run loop source when starting with events of interest`() {
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
  func `Does nothing when event tap creation fails`() {
    let (cgEventMock, _, _, sut) = makeMockManager()
    cgEventMock._createEventTap = { _, _, _, _, _ in nil }

    sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(sut.taps["test"] == nil)
    #expect(sut.runLoopSources["test"] == nil)
  }

  @Test
  func `Invokes client callback when event handler is triggered`() throws {
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
      _ = box.eventHandler(proxy, .flagsChanged, try #require(.init(keyboardEventSource: nil, virtualKey: 0, keyDown: true)))
    }

    #expect(clientCallbackCalls == 1)
  }

  @Test
  func `Calls CGEventClient.createEventTap once with correct parameters`() {
    nonisolated(unsafe) var createEventTapCalls = 0
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
      createEventTapCalls += 1
      return mockMachPort
    }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }

    sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(createEventTapCalls == 1)
  }

  @Test
  func `Calls CFMachPortClientProtocol.createRunLoopSource once with correct parameters`() {
    nonisolated(unsafe) var createRunLoopSourceCalls = 0
    let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { port, order in
      #expect(port === mockMachPort)
      #expect(order == 0)
      createRunLoopSourceCalls += 1
      return mockRunLoopSource
    }

    sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(createRunLoopSourceCalls == 1)
  }

  @Test
  func `Calls CFRunLoopClient.add once with correct parameters`() {
    nonisolated(unsafe) var addCalls = 0
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfRunLoopMock._add = { source, runLoop, mode in
      #expect(source === mockRunLoopSource)
      #expect(runLoop === CFRunLoopGetMain())
      #expect(mode == .commonModes)
      addCalls += 1
    }

    sut.start(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(addCalls == 1)
  }

  @Test
  func `Does nothing when starting with duplicate ID`() {
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
    nonisolated(unsafe) var createEventTapCallCount = 0
    nonisolated(unsafe) var createRunLoopSourceCallCount = 0
    nonisolated(unsafe) var addCallCount = 0

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
  func `Calls CFRunLoopClient.remove once with correct parameters`() {
    nonisolated(unsafe) var removeCalls = 0
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
      removeCalls += 1
    }

    sut.stop(id: "test")

    #expect(removeCalls == 1)
  }

  @Test
  func `Calls CFMachPortClientProtocol.invalidate once with correct parameters`() {
    nonisolated(unsafe) var invalidateCalls = 0
    let (_, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "A")
    let mockRunLoopSource = RunLoopSourceMock(id: "B")
    sut.taps["test"] = mockMachPort
    sut.runLoopSources["test"] = mockRunLoopSource

    cfMachPortMock._invalidate = { machPort in
      #expect(machPort === mockMachPort)
      invalidateCalls += 1
    }
    cfRunLoopMock._remove = { (_: RunLoopSourceMock, _: CFRunLoop, _: CFRunLoopMode) in }

    sut.stop(id: "test")

    #expect(invalidateCalls == 1)
  }

  @Test
  func `Cleans up all internal state when stopping`() {
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
  func `Calls CGEventClient.getEnabled once with correct parameters and returns result`() {
    nonisolated(unsafe) var getEnabledCalls = 0
    let (cgEventMock, _, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "A")
    cgEventMock._getEnabled = { tap in
      #expect(tap === mockMachPort)
      getEnabledCalls += 1
      return true
    }
    sut.taps["test"] = mockMachPort

    let result = sut.getIsEnabled(id: "test")

    #expect(result == true)
    #expect(getEnabledCalls == 1)
  }

  @Test
  func `Returns false when no event tap exists`() {
    let (_, _, _, sut) = makeMockManager()

    let result = sut.getIsEnabled(id: "test")

    #expect(result == false)
  }

  @Test
  func `Calls CGEventClient.setEnabled once with correct parameters`() {
    nonisolated(unsafe) var setEnabledCalls = 0
    let (cgEventMock, _, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "F")
    sut.taps["test"] = mockMachPort

    cgEventMock._setEnabled = { tap, isEnabled in
      #expect(tap === mockMachPort)
      #expect(isEnabled == true)
      setEnabledCalls += 1
    }

    sut.setIsEnabled(id: "test", true)

    #expect(setEnabledCalls == 1)
  }

  @Test
  func `Does nothing when no event tap exists`() {
    let (cgEventMock, _, _, sut) = makeMockManager()

    nonisolated(unsafe) var setEnabledCalled = false
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
  manager: EventTapManager<CGEventClientMock, CFMachPortClientMock, CFRunLoopClientMock>,
) {
  let cgEventMock = CGEventClientMock()
  let cfMachPortMock = CFMachPortClientMock()
  let cfRunLoopMock = CFRunLoopClientMock()
  let manager = RBKit.EventTapManager(
    cgEventClient: cgEventMock,
    cfMachPortClient: cfMachPortMock,
    cfRunLoopClient: cfRunLoopMock,
  )
  return (cgEventMock, cfMachPortMock, cfRunLoopMock, manager)
}
