import Carbon
import RBKit
import Testing

@testable import RBKit

// MARK: - EventTapManagerTests

@MainActor
struct EventTapManagerTests {

  @Test
  func `Creates event tap and run loop source when adding events of interest`() async {
    let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")
    var createRunLoopSourceCalls = 0

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in
      createRunLoopSourceCalls += 1
      return mockRunLoopSource
    }

    await sut.add(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(createRunLoopSourceCalls == 1)
  }

  @Test
  func `Does nothing when event tap creation fails`() async {
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    var createRunLoopSourceCalls = 0
    var addCalls = 0
    cgEventMock._createEventTap = { _, _, _, _, _ in nil }
    cfMachPortMock._createRunLoopSource = { _, _ in
      createRunLoopSourceCalls += 1
      return RunLoopSourceMock(id: "RUN_LOOP_SOURCE")
    }
    cfRunLoopMock._addSource = { _, _, _ in addCalls += 1 }

    await sut.add(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(createRunLoopSourceCalls == 0)
    #expect(addCalls == 0)
  }

  @Test
  func `Invokes client callback when event handler is triggered`() async throws {
    let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")
    var userInfo: UnsafeMutableRawPointer?

    cgEventMock._createEventTap = { _, _, _, _, eventTapUserInfo in
      userInfo = eventTapUserInfo
      return mockMachPort
    }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    var clientCallbackCalls = 0

    await sut.add(id: "test", eventsOfInterest: []) { _, _ in
      clientCallbackCalls += 1
      return nil
    }

    let box = Unmanaged<BoxedEventHandler>
      .fromOpaque(try #require(userInfo))
      .takeUnretainedValue()
    let proxy = unsafeBitCast(0, to: CGEventTapProxy.self)
    _ = box.eventHandler(proxy, .flagsChanged, try #require(.init(keyboardEventSource: nil, virtualKey: 0, keyDown: true)))

    #expect(clientCallbackCalls == 1)
  }

  @Test
  func `Calls CGEventClient.createEventTap once with correct parameters`() async {
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

    await sut.add(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(createEventTapCalls == 1)
  }

  @Test
  func `Calls CFMachPortClientProtocol.createRunLoopSource once with correct parameters`() async {
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

    await sut.add(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(createRunLoopSourceCalls == 1)
  }

  @Test
  func `Calls CFRunLoopClient.add once with correct parameters`() async {
    nonisolated(unsafe) var addCalls = 0
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")
    let currentRunLoop = CFRunLoopGetMain()

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfRunLoopMock._getCurrent = { currentRunLoop }
    cfRunLoopMock._addSource = { runLoop, source, mode in
      #expect(source === mockRunLoopSource)
      #expect(runLoop === currentRunLoop)
      #expect(mode == .commonModes)
      addCalls += 1
    }

    await sut.add(id: "test", eventsOfInterest: [.keyDown, .flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    #expect(addCalls == 1)
  }

  @Test
  func `Does nothing when adding duplicate ID`() async {
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "TAP")
    let mockRunLoopSource = RunLoopSourceMock(id: "RUN_LOOP_SOURCE")

    // Set up first tap
    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfRunLoopMock._addSource = { (_: CFRunLoop, _: RunLoopSourceMock, _: CFRunLoopMode) in }

    await sut.add(id: "test", eventsOfInterest: [.keyDown]) { _, _ in nil }

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
    cfRunLoopMock._addSource = { (_: CFRunLoop, _: RunLoopSourceMock, _: CFRunLoopMode) in
      addCallCount += 1
    }

    // Attempt to start with same ID
    await sut.add(id: "test", eventsOfInterest: [.flagsChanged]) { (_: CGEventType, _: CGEvent) in nil }

    // Verify no dependencies were called for duplicate ID
    #expect(createEventTapCallCount == 0)
    #expect(createRunLoopSourceCallCount == 0)
    #expect(addCallCount == 0)
  }

  @Test
  func `Calls CFRunLoopClient.remove once with correct parameters`() async {
    nonisolated(unsafe) var removeCalls = 0
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "A")
    let mockRunLoopSource = RunLoopSourceMock(id: "B")
    let currentRunLoop = CFRunLoopGetMain()

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfMachPortMock._invalidate = { (_: MachPortMock) in }
    cfRunLoopMock._getCurrent = { currentRunLoop }
    cfRunLoopMock._removeSource = { runLoop, source, mode in
      #expect(source === mockRunLoopSource)
      #expect(runLoop === currentRunLoop)
      #expect(mode == .commonModes)
      removeCalls += 1
    }

    await sut.add(id: "test", eventsOfInterest: [.keyDown]) { _, _ in nil }
    await sut.remove(id: "test")

    #expect(removeCalls == 1)
  }

  @Test
  func `Calls CFMachPortClientProtocol.invalidate once with correct parameters`() async {
    nonisolated(unsafe) var invalidateCalls = 0
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "A")
    let mockRunLoopSource = RunLoopSourceMock(id: "B")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfMachPortMock._invalidate = { machPort in
      #expect(machPort === mockMachPort)
      invalidateCalls += 1
    }
    cfRunLoopMock._removeSource = { (_: CFRunLoop, _: RunLoopSourceMock, _: CFRunLoopMode) in }

    await sut.add(id: "test", eventsOfInterest: [.keyDown]) { _, _ in nil }
    await sut.remove(id: "test")

    #expect(invalidateCalls == 1)
  }

  @Test
  func `Cleans up all internal state when removing`() async {
    var removeCalls = 0
    var invalidateCalls = 0
    let (cgEventMock, cfMachPortMock, cfRunLoopMock, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "A")
    let mockRunLoopSource = RunLoopSourceMock(id: "B")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in mockRunLoopSource }
    cfMachPortMock._invalidate = { (_: MachPortMock) in invalidateCalls += 1 }
    cfRunLoopMock._removeSource = { (_: CFRunLoop, _: RunLoopSourceMock, _: CFRunLoopMode) in removeCalls += 1 }

    await sut.add(id: "test", eventsOfInterest: [.keyDown]) { _, _ in nil }
    await sut.remove(id: "test")
    await sut.remove(id: "test")

    #expect(removeCalls == 1)
    #expect(invalidateCalls == 1)
  }

  @Test
  func `Calls CGEventClient.setEnabled once with correct parameters`() async {
    nonisolated(unsafe) var setEnabledCalls = 0
    let (cgEventMock, cfMachPortMock, _, sut) = makeMockManager()
    let mockMachPort = MachPortMock(id: "F")

    cgEventMock._createEventTap = { _, _, _, _, _ in mockMachPort }
    cfMachPortMock._createRunLoopSource = { _, _ in RunLoopSourceMock(id: "B") }
    cgEventMock._setEnabled = { tap, isEnabled in
      #expect(tap === mockMachPort)
      #expect(isEnabled == true)
      setEnabledCalls += 1
    }

    await sut.add(id: "test", eventsOfInterest: [.keyDown]) { _, _ in nil }
    await sut.setIsEnabled(id: "test", true)

    #expect(setEnabledCalls == 1)
  }

  @Test
  func `setIsEnabled, without event tap, should assert`() async {
    await #expect(processExitsWith: .failure) {
      let (_, _, _, sut) = makeMockManager()
      await sut.setIsEnabled(id: "test", false)
    }
  }
}

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
