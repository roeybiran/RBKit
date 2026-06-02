@preconcurrency import Carbon

actor EventTapManager<
  EventClient: CGEventClientProtocol,
  MachPortClient: CFMachPortClientProtocol,
  RunLoopClient: CFRunLoopClientProtocol,
> where
  EventClient.MachPort == MachPortClient.MachPort,
  MachPortClient.RunLoopSource == RunLoopClient.RunLoopSource
{

  // MARK: Lifecycle

  init(
    cgEventClient: EventClient,
    cfMachPortClient: MachPortClient,
    cfRunLoopClient: RunLoopClient,
  ) {
    self.cgEventClient = cgEventClient
    self.cfMachPortClient = cfMachPortClient
    self.cfRunLoopClient = cfRunLoopClient
  }

  // MARK: Internal

  typealias ID = EventTapManagerClient.ID

  struct ActiveTap {
    var box: BoxedEventHandler
    var machPort: EventClient.MachPort
    var runLoopSource: MachPortClient.RunLoopSource
  }

  var activeTaps = [ID: ActiveTap]()

  let cgEventClient: EventClient
  let cfMachPortClient: MachPortClient
  let cfRunLoopClient: RunLoopClient

  func add(
    id: ID,
    eventsOfInterest: [CGEventType],
    place: CGEventTapPlacement = .headInsertEventTap,
    clientCallback: @escaping EventTapManagerClient.Callback,
  ) {
    guard activeTaps[id] == nil else { return }

    let eventsOfInterestMask = (eventsOfInterest + [.tapDisabledByTimeout, .tapDisabledByUserInput])
      .map { 1 << $0.rawValue }
      .reduce(CGEventMask(), |)

    let box = BoxedEventHandler()
    box.eventHandler = { _, type, event in
      clientCallback(type, event).map { Unmanaged.passUnretained($0) }
    }
    let machPort = cgEventClient.createEventTap(
      tap: .cgSessionEventTap,
      place: place,
      options: .defaultTap,
      eventsOfInterest: eventsOfInterestMask,
      userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(box).toOpaque()),
    )

    guard let machPort else { return }
    guard let runLoop = cfRunLoopClient.getCurrent() else {
      cfMachPortClient.invalidate(machPort: machPort)
      return
    }

    let runLoopSource = cfMachPortClient.createRunLoopSource(port: machPort, order: 0)
    let runLoopMode = CFRunLoopMode.commonModes as CFRunLoopMode
    cfRunLoopClient.addSource(runLoop: runLoop, source: runLoopSource, mode: runLoopMode)
    activeTaps[id] = .init(box: box, machPort: machPort, runLoopSource: runLoopSource)
  }

  func remove(id: ID) {
    guard
      let runLoop = cfRunLoopClient.getCurrent(),
      let activeTap = activeTaps.removeValue(forKey: id)
    else { return }

    let runLoopMode = CFRunLoopMode.commonModes as CFRunLoopMode
    cfRunLoopClient.removeSource(runLoop: runLoop, source: activeTap.runLoopSource, mode: runLoopMode)
    cfMachPortClient.invalidate(machPort: activeTap.machPort)
  }

  func setIsEnabled(id: ID, _ enabled: Bool) {
    guard let machPort = activeTaps[id]?.machPort else {
      assertionFailure("Expected event tap for id '\(id)' to exist before setting enabled state.")
      return
    }
    cgEventClient.setEnabled(tap: machPort, isEnabled: enabled)
  }

}
