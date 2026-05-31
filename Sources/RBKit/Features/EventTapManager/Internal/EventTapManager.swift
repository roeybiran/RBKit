@preconcurrency import Carbon

@MainActor
final class EventTapManager<
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

  var boxes = [ID: BoxedEventHandler]()
  var taps = [ID: EventClient.MachPort]()
  var runLoopSources = [ID: MachPortClient.RunLoopSource]()

  let cgEventClient: EventClient
  let cfMachPortClient: MachPortClient
  let cfRunLoopClient: RunLoopClient

  func start(
    id: ID,
    eventsOfInterest: [CGEventType],
    place: CGEventTapPlacement = .headInsertEventTap,
    clientCallback: @escaping EventTapManagerClient.Callback,
  ) {
    guard taps[id] == nil else { return }

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

    boxes[id] = box
    taps[id] = machPort

    let runLoopSource = cfMachPortClient.createRunLoopSource(port: machPort, order: 0)
    cfRunLoopClient.addSource(runLoop: runLoop, source: runLoopSource, mode: .commonModes)
    runLoopSources[id] = runLoopSource
  }

  func stop(id: ID) {
    guard
      let runLoop = cfRunLoopClient.getCurrent(),
      let runLoopSource = runLoopSources.removeValue(forKey: id),
      let machPort = taps.removeValue(forKey: id)
    else { return }

    cfRunLoopClient.removeSource(runLoop: runLoop, source: runLoopSource, mode: .commonModes)
    cfMachPortClient.invalidate(machPort: machPort)

    boxes.removeValue(forKey: id)
  }

  func setIsEnabled(id: ID, _ enabled: Bool) {
    guard let machPort = taps[id] else {
      assertionFailure("Expected event tap for id '\(id)' to exist before setting enabled state.")
      return
    }
    cgEventClient.setEnabled(tap: machPort, isEnabled: enabled)
  }

}
