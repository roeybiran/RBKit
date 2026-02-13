import Carbon

/// EventTapManager
/// ## See Also:
/// - [All about macOS event observation](https://docs.google.com/presentation/d/1nEaiPUduh1vjks0rDVRTcJaEULbSWWh1tVdG2HF_XSU/htmlpresent)
/// - [Mac OS X Internals, Bonus Content, Chapter 2: An Overview of Mac OS X, Receiving, Filtering, and Modifying Key Presses and Releases](https://web.archive.org/web/20200503003001/http://osxbook.com/book/bonus/chapter2/alterkeys/)
/// - [github.com/pqrs-org/osx-event-observer-examples](https://github.com/pqrs-org/osx-event-observer-examples)
/// - https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/logic/events/KeyboardEvents.swift#L84
/// - https://github.com/zenangst/KeyboardCowboy/blob/main/App/Sources/Core/Runners/MachPortCoordinator.swift
/// - https://github.com/zenangst/MachPort/blob/main/Sources/MachPort/MachPortEventController.swift
/// - https://github.com/rxhanson/Rectangle/blob/59080f5cdb23dee5f3ae3ad76b1e5ee62f344a37/Rectangle/Utilities/EventMonitor.swift#L75
/// - https://stackoverflow.com/questions/31891002/how-do-you-use-cgeventtapcreate-in-swift
/// - https://stackoverflow.com/questions/15573376/registereventhotkey-cmdtab-in-mountain-lion
/// - https://stackoverflow.com/questions/3237338/shortcutrecorder-record-cmdtab
/// - https://stackoverflow.com/questions/26673329/using-cgeventtapcreate-trouble-with-parameters-in-swift
/// - https://stackoverflow.com/questions/2969110/cgeventtapcreate-breaks-down-mysteriously-with-key-down-events
/// - https://github.com/JanX2/ShortcutRecorder
/// - https://github.com/numist/Switch/blob/7d5cda1411c939a5229c80e6b194ae79d6fc41ef/Switch/SWEventTap.m#L175
/// - https://stackoverflow.com/questions/33294620/how-to-cast-self-to-unsafemutablepointervoid-type-in-swift

@MainActor
final class EventTapManager<
  EventClient: CGEventClientProtocol,
  MachPortClient: CFMachPortClientProtocol,
  RunLoopClient: CFRunLoopClientProtocol
> where
  EventClient.MachPort == MachPortClient.MachPort,
  MachPortClient.RunLoopSource == RunLoopClient.RunLoopSource
{

  // MARK: Lifecycle

  init(
    cgEventClient: EventClient,
    cfMachPortClient: MachPortClient,
    cfRunLoopClient: RunLoopClient
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
    clientCallback: @escaping EventTapManagerClient.Callback
  ) {
    assert(Thread.isMainThread)

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
      userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(box).toOpaque())
    )

    guard let machPort else { return }

    boxes[id] = box
    taps[id] = machPort

    let runLoopSource = cfMachPortClient.createRunLoopSource(port: machPort, order: 0)
    cfRunLoopClient.add(source: runLoopSource, to: CFRunLoopGetMain(), mode: .commonModes)
    runLoopSources[id] = runLoopSource
  }

  func stop(id: ID) {
    guard
      let runLoopSource = runLoopSources.removeValue(forKey: id),
      let machPort = taps.removeValue(forKey: id)
    else { return }

    cfRunLoopClient.remove(source: runLoopSource, from: CFRunLoopGetMain(), mode: .commonModes)
    cfMachPortClient.invalidate(machPort: machPort)

    boxes.removeValue(forKey: id)
  }

  func getIsEnabled(id: ID) -> Bool {
    guard let machPort = taps[id] else { return false }
    return cgEventClient.getEnabled(tap: machPort)
  }

  func setIsEnabled(id: ID, _ enabled: Bool) {
    guard let machPort = taps[id] else { return }
    cgEventClient.setEnabled(tap: machPort, isEnabled: enabled)
  }

}
