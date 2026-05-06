import AppKit
import Carbon
import Dependencies
import Foundation

// MARK: - HotKeyManager

@MainActor
final class HotKeyManager {

  // MARK: Internal

  typealias HotKeyHandler = (_ event: EventType) -> Void

  @Dependency(\.userDefaultsClient) var userDefaultsClient
  @Dependency(\.carbonEventsCoreClient) var carbonEventsCoreClient
  @Dependency(\.nsApplicationClient) var nsApplicationClient
  @Dependency(\.nsEventClient) var nsEventClient
  @Dependency(\.continuousClock) var continuousClock

  private(set) var activeRegistrations = [HotKey.ID: RegisteredHotKey]()
  private(set) var activeHotKeyIDs = [HotKey: HotKey.ID]()
  private(set) var hotKeyStatuses = [HotKey.ID: HotKeyStatus]()
  private(set) var eventHandlerRef: EventHandlerRef?
  private(set) var handlers = [HotKey.ID: HotKeyHandler]()
  private(set) var isResumed = false
  private(set) var eventHotKeyTask: Task<Void, Never>?

  func start() {
    if isResumed { return }

    isResumed = true

    (userDefaultsClient.dictionary(forKey: .DEFAULTS_ALL_HOT_KEYS_KEY) ?? [:])
      .compactMap { idKey, value -> (id: HotKey.ID, hotKey: HotKey)? in
        if
          let id = Int(idKey),
          let dict = value as? [String: Any],
          let keyCode = dict[.DEFAULTS_KEY_CODE_KEY] as? Int,
          let key = Key(rawValue: keyCode),
          let carbonModifiers = dict[.DEFAULTS_MODIFIERS_KEY] as? Int
        {
          return (
            id: id,
            hotKey: HotKey(key: key, modifiers: Modifiers(carbon: carbonModifiers)),
          )
        } else {
          return nil
        }
      }
      .forEach { hotKey in
        register(hotKey: hotKey.hotKey, id: hotKey.id)
      }

    if eventHandlerRef != nil { return }
    guard let eventTargetRef = carbonEventsCoreClient.getEventDispatcherTarget() else { return }

    eventHandlerBox.callback = { [self] event in
      handle(event: event)
    }
    let (eventHandlerRef, status) = carbonEventsCoreClient.installEventHandler(
      eventTargetRef,
      Self.eventTypeSpecs.count,
      Self.eventTypeSpecs,
      eventHandlerBox,
    )
    if status == noErr {
      self.eventHandlerRef = eventHandlerRef
    }
  }

  func stop() {
    if !isResumed { return }

    isResumed = false
    eventHotKeyTask?.cancel()
    eventHotKeyTask = nil

    for registration in activeRegistrations.values {
      _ = carbonEventsCoreClient.unregisterEventHotKey(registration.ref)
    }
    activeRegistrations.removeAll()
    activeHotKeyIDs.removeAll()
  }

  func registerDefaults(_ defaults: [HotKey.ID: HotKey]) {
    let serializedDefaults = defaults.reduce(into: [String: [String: Int]]()) { result, element in
      result[String(element.key)] = [
        String.DEFAULTS_KEY_CODE_KEY: element.value.key.keyCode,
        .DEFAULTS_MODIFIERS_KEY: element.value.modifiers.carbon,
      ]
    }
    userDefaultsClient.register([.DEFAULTS_ALL_HOT_KEYS_KEY: serializedDefaults])
  }

  func register(hotKey: HotKey, id: HotKey.ID, exclusive: Bool = true) {
    if activeRegistrations[id]?.hotKey == hotKey { return }

    if let existingID = activeHotKeyIDs[hotKey], existingID != id {
      hotKeyStatuses[id] = .failedToRegister(hotKey: hotKey, error: .userConflict)
      return
    }

    if let registration = activeRegistrations[id] {
      _ = carbonEventsCoreClient.unregisterEventHotKey(registration.ref)
      activeHotKeyIDs.removeValue(forKey: registration.hotKey)
    }

    guard let carbonID = UInt32(exactly: id) else {
      assertionFailure("HotKey ID must fit UInt32")
      hotKeyStatuses[id] = .failedToRegister(hotKey: hotKey, error: .unknown)
      return
    }

    guard let eventTargetRef = carbonEventsCoreClient.getEventDispatcherTarget() else {
      hotKeyStatuses[id] = .failedToRegister(hotKey: hotKey, error: .unknown)
      return
    }

    let (hotkeyRef, status) = carbonEventsCoreClient.registerEventHotKey(
      UInt32(hotKey.key.keyCode),
      UInt32(hotKey.modifiers.carbon),
      EventHotKeyID(signature: .HOT_KEY_SIGNATURE, id: carbonID),
      eventTargetRef,
      UInt32(exclusive ? kEventHotKeyExclusive : kEventHotKeyNoOptions),
    )

    if status == eventHotKeyExistsErr {
      activeRegistrations.removeValue(forKey: id)
      activeHotKeyIDs.removeValue(forKey: hotKey)
      hotKeyStatuses[id] = .failedToRegister(hotKey: hotKey, error: .carbonHotKeyExists)
      return
    }

    guard status == noErr, let hotkeyRef else {
      activeRegistrations.removeValue(forKey: id)
      activeHotKeyIDs.removeValue(forKey: hotKey)
      hotKeyStatuses[id] = .failedToRegister(hotKey: hotKey, error: .unknown)
      return
    }

    activeRegistrations[id] = RegisteredHotKey(ref: hotkeyRef, hotKey: hotKey)
    activeHotKeyIDs[hotKey] = id
    hotKeyStatuses[id] = .registered(hotKey)

    var container = userDefaultsClient.dictionary(forKey: .DEFAULTS_ALL_HOT_KEYS_KEY) ?? [:]
    container[String(id)] = [
      String.DEFAULTS_KEY_CODE_KEY: hotKey.key.keyCode,
      .DEFAULTS_MODIFIERS_KEY: hotKey.modifiers.carbon,
    ]
    userDefaultsClient.setAny(container, .DEFAULTS_ALL_HOT_KEYS_KEY)
  }

  func unregister(id: HotKey.ID) {
    let registration = activeRegistrations.removeValue(forKey: id)
    if let registration {
      activeHotKeyIDs.removeValue(forKey: registration.hotKey)
    }
    hotKeyStatuses.removeValue(forKey: id)

    var container = userDefaultsClient.dictionary(forKey: .DEFAULTS_ALL_HOT_KEYS_KEY) ?? [:]
    container.removeValue(forKey: String(id))
    userDefaultsClient.setAny(container, .DEFAULTS_ALL_HOT_KEYS_KEY)

    if let registration {
      _ = carbonEventsCoreClient.unregisterEventHotKey(registration.ref)
    }
  }

  func status(of id: HotKey.ID) -> HotKeyStatus? {
    hotKeyStatuses[id]
  }

  func presses(of id: HotKey.ID) -> AsyncStream<EventType> {
    AsyncStream { continuation in
      handlers[id] = { event in
        continuation.yield(event)
      }
    }
  }

  // MARK: Private

  private static let eventTypeSpecs = [
    EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyPressed),
    ),
    EventTypeSpec(
      eventClass: OSType(kEventClassKeyboard),
      eventKind: UInt32(kEventHotKeyReleased),
    ),
  ]

  private let eventHandlerBox = BoxedHotKeyHandler()

  private func handle(event: EventRef?) -> OSStatus {
    guard let event else {
      return OSStatus(eventNotHandledErr)
    }

    var eventHotKeyId = EventHotKeyID()
    let error = carbonEventsCoreClient.getEventParameter(
      event,
      UInt32(kEventParamDirectObject),
      UInt32(typeEventHotKeyID),
      nil,
      MemoryLayout<EventHotKeyID>.size,
      nil,
      &eventHotKeyId,
    )
    let hotKeyID = Int(eventHotKeyId.id)

    guard
      error == noErr,
      eventHotKeyId.signature == .HOT_KEY_SIGNATURE,
      let userHandler = handlers[hotKeyID]
    else {
      return OSStatus(eventNotHandledErr)
    }

    if activeRegistrations[hotKeyID] == nil {
      return OSStatus(eventNotHandledErr)
    }

    let eventType: EventType
    switch Int(carbonEventsCoreClient.getEventKind(event)) {
    case kEventHotKeyPressed:
      eventType = .keyDown

    case kEventHotKeyReleased:
      eventType = .keyUp

    default:
      return noErr
    }

    switch eventType.kind {
    case .keyDown:
      startEventHotKeySequence(id: hotKeyID)

    case .keyUp:
      eventHotKeyTask?.cancel()
      eventHotKeyTask = nil
      userHandler(eventType)
    }

    return noErr
  }

  private func startEventHotKeySequence(id: HotKey.ID) {
    let delay = Duration.seconds(nsEventClient.keyRepeatDelay())
    let interval = Duration.seconds(nsEventClient.keyRepeatInterval())
    let repeatingKey = activeRegistrations[id]?.hotKey.key

    handlers[id]?(.keyDown)

    eventHotKeyTask?.cancel()
    eventHotKeyTask = Task { [continuousClock] in
      var currentID = id
      try? await continuousClock.sleep(for: delay)
      while !Task.isCancelled {
        if
          let repeatingKey,
          let currentEvent = nsApplicationClient.currentEvent(),
          currentEvent.type == .flagsChanged
        {
          let hotKey = HotKey(key: repeatingKey, modifiers: Modifiers(cocoa: currentEvent.modifierFlags))
          currentID = activeHotKeyIDs[hotKey] ?? currentID
        }
        handlers[currentID]?(.init(kind: .keyDown, isRepeat: true))
        try? await continuousClock.sleep(for: interval)
      }
    }
  }
}
