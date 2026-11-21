import AppKit
import Carbon
import Dependencies
import DependenciesTestSupport
import Testing
@testable import RBKit

// MARK: - HotKeyManagerTests

@Suite(.dependencies {
  $0.continuousClock = TestClock<Duration>()
  $0.nsApplicationClient.currentEvent = { nil }
  $0.nsEventClient.keyRepeatDelay = { 3600 }
  $0.nsEventClient.keyRepeatInterval = { 3600 }
})
@MainActor
struct HotKeyManagerTests {
  @Test
  func `registerDefaults should register stringified ids`() {
    nonisolated(unsafe) var defaults = [String: Any]()

    let sut = withDependencies {
      $0.userDefaultsClient.register = { defaults = $0 }
    } operation: {
      HotKeyManager()
    }

    sut.registerDefaults([
      1: .init(key: .a, modifiers: [.command]),
      2: .init(key: .f2, modifiers: []),
    ])

    let serializedDefaults = defaults[.DEFAULTS_ALL_HOT_KEYS_KEY] as? [String: [String: Int]]
    #expect(
      [
        "1": [
          .DEFAULTS_KEY_CODE_KEY: Key.a.keyCode,
          .DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command]).carbon,
        ],
        "2": [
          .DEFAULTS_KEY_CODE_KEY: Key.f2.keyCode,
          .DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: []).carbon,
        ],
      ]
        == serializedDefaults
    )
  }

  @Test
  func `start should load id keyed defaults and install event handler`() throws {
    nonisolated(unsafe) var registeredIDs = [UInt32]()
    nonisolated(unsafe) var installCalls = 0

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in
        [
          "1": [
            String.DEFAULTS_KEY_CODE_KEY: Key.f2.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: []).carbon,
          ],
          "2": [
            String.DEFAULTS_KEY_CODE_KEY: Key.v.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command, .control, .option, .shift]).carbon,
          ],
          "3": [
            String.DEFAULTS_KEY_CODE_KEY: Int(kVK_Command),
            String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: []).carbon,
          ],
          "legacyName": [
            String.DEFAULTS_KEY_CODE_KEY: Key.z.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: []).carbon,
          ],
        ]
      }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, _ in
        installCalls += 1
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, hotKeyID, _, _ in
        registeredIDs.append(hotKeyID.id)
        return (OpaquePointer(bitPattern: Int(hotKeyID.id) + 10), noErr)
      }
    } operation: {
      HotKeyManager()
    }

    sut.start()

    #expect(installCalls == 1)
    #expect(registeredIDs.sorted() == [1, 2])
    let hotKey1 = HotKey(key: .f2, modifiers: [])
    let registration1 = try #require(sut.activeRegistrations[1], "Expected a registered hot key for id 1")
    #expect(registration1.ref == OpaquePointer(bitPattern: 11))
    #expect(registration1.hotKey == hotKey1)
    #expect(sut.hotKeyStatuses[1] == .registered(hotKey1))
    let hotKey2 = HotKey(key: .v, modifiers: [.command, .control, .option, .shift])
    let registration2 = try #require(sut.activeRegistrations[2], "Expected a registered hot key for id 2")
    #expect(registration2.ref == OpaquePointer(bitPattern: 12))
    #expect(registration2.hotKey == hotKey2)
    #expect(sut.hotKeyStatuses[2] == .registered(hotKey2))
    #expect(sut.activeRegistrations[3] == nil)
    #expect(sut.hotKeyStatuses[3] == nil)
    #expect(sut.eventHandlerRef == mockEventHandlerRef)
    #expect(sut.isResumed)
  }

  @Test
  func `start after stop should reuse the installed handler and re-register defaults`() throws {
    nonisolated(unsafe) var installCalls = 0
    nonisolated(unsafe) var registerCalls = 0
    nonisolated(unsafe) var unregisteredRefs = [EventHotKeyRef]()

    let hotKey = HotKey(key: .a, modifiers: [.command])
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in
        [
          "1": [
            String.DEFAULTS_KEY_CODE_KEY: hotKey.key.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: hotKey.modifiers.carbon,
          ]
        ]
      }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, _ in
        installCalls += 1
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, hotKeyID, _, _ in
        registerCalls += 1
        return (OpaquePointer(bitPattern: Int(hotKeyID.id) + registerCalls), noErr)
      }
      $0.carbonEventsCoreClient.unregisterEventHotKey = {
        unregisteredRefs.append($0)
        return noErr
      }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    let firstRef = try #require(sut.activeRegistrations[1]?.ref)
    sut.stop()
    sut.start()

    #expect(installCalls == 1)
    #expect(unregisteredRefs == [firstRef])
    #expect(registerCalls == 2)
    #expect(sut.eventHandlerRef == mockEventHandlerRef)
    #expect(sut.isResumed)
    #expect(sut.activeRegistrations[1]?.hotKey == hotKey)
    #expect(sut.activeRegistrations[1]?.ref != firstRef)
  }

  @Test
  func `start, when already resumed, should do nothing`() {
    nonisolated(unsafe) var installCalls = 0
    nonisolated(unsafe) var registerCalls = 0

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in
        [
          "1": [
            String.DEFAULTS_KEY_CODE_KEY: Key.a.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: Modifiers(cocoa: [.command]).carbon,
          ]
        ]
      }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, _ in
        installCalls += 1
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in
        registerCalls += 1
        return (mockEventHotKeyRef, noErr)
      }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    sut.start()

    #expect(installCalls == 1)
    #expect(registerCalls == 1)
  }

  @Test
  func `start, when installing the event handler fails, should leave eventHandlerRef nil`() {
    nonisolated(unsafe) var installCalls = 0

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, _ in
        installCalls += 1
        return (nil, OSStatus(eventNotHandledErr))
      }
    } operation: {
      HotKeyManager()
    }

    sut.start()

    #expect(installCalls == 1)
    #expect(sut.eventHandlerRef == nil)
    #expect(sut.isResumed)
  }

  @Test
  func `register should store a successful registration`() throws {
    nonisolated(unsafe) var keyCode: UInt32?
    nonisolated(unsafe) var modifiers: UInt32?
    nonisolated(unsafe) var hotKeyID: EventHotKeyID?
    nonisolated(unsafe) var target: EventTargetRef?
    nonisolated(unsafe) var options: UInt32?
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = {
        receivedKeyCode,
          receivedModifiers,
          receivedHotKeyID,
          receivedTarget,
          receivedOptions in
        keyCode = receivedKeyCode
        modifiers = receivedModifiers
        hotKeyID = receivedHotKeyID
        target = receivedTarget
        options = receivedOptions
        return (mockEventHotKeyRef, noErr)
      }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: hotKey, id: 1)

    let registration = try #require(sut.activeRegistrations[1], "Expected a registered hot key for id 1")
    let forwardedHotKeyID = try #require(hotKeyID)
    #expect(registration.ref == mockEventHotKeyRef)
    #expect(registration.hotKey == hotKey)
    #expect(sut.hotKeyStatuses[1] == .registered(hotKey))
    #expect(keyCode == UInt32(hotKey.key.keyCode))
    #expect(modifiers == UInt32(hotKey.modifiers.carbon))
    #expect(forwardedHotKeyID.signature == .HOT_KEY_SIGNATURE)
    #expect(forwardedHotKeyID.id == 1)
    #expect(target == mockEventDispatcherTarget)
    #expect(options == UInt32(kEventHotKeyExclusive))
  }

  @Test
  func `register with exclusive false should use no options`() throws {
    nonisolated(unsafe) var keyCode: UInt32?
    nonisolated(unsafe) var modifiers: UInt32?
    nonisolated(unsafe) var hotKeyID: EventHotKeyID?
    nonisolated(unsafe) var target: EventTargetRef?
    nonisolated(unsafe) var options: UInt32?
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = {
        receivedKeyCode,
          receivedModifiers,
          receivedHotKeyID,
          receivedTarget,
          receivedOptions in
        keyCode = receivedKeyCode
        modifiers = receivedModifiers
        hotKeyID = receivedHotKeyID
        target = receivedTarget
        options = receivedOptions
        return (mockEventHotKeyRef, noErr)
      }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: hotKey, id: 1, exclusive: false)

    let forwardedHotKeyID = try #require(hotKeyID)
    #expect(keyCode == UInt32(hotKey.key.keyCode))
    #expect(modifiers == UInt32(hotKey.modifiers.carbon))
    #expect(forwardedHotKeyID.signature == .HOT_KEY_SIGNATURE)
    #expect(forwardedHotKeyID.id == 1)
    #expect(target == mockEventDispatcherTarget)
    #expect(options == UInt32(kEventHotKeyNoOptions))
    #expect(sut.hotKeyStatuses[1] == .registered(hotKey))
  }

  @Test
  func `register with the same hot key for the same id should be a no-op`() throws {
    nonisolated(unsafe) var registerCalls = 0
    nonisolated(unsafe) var unregisterCalls = 0
    nonisolated(unsafe) var setAnyCalls = 0

    let hotKey = HotKey(key: .a, modifiers: [.command])
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in setAnyCalls += 1 }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in
        registerCalls += 1
        return (OpaquePointer(bitPattern: registerCalls + 100), noErr)
      }
      $0.carbonEventsCoreClient.unregisterEventHotKey = { _ in
        unregisterCalls += 1
        return noErr
      }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: hotKey, id: 1)
    let firstRef = try #require(sut.activeRegistrations[1]?.ref)
    sut.register(hotKey: hotKey, id: 1)

    #expect(registerCalls == 1)
    #expect(unregisterCalls == 0)
    #expect(setAnyCalls == 1)
    #expect(sut.activeRegistrations[1]?.ref == firstRef)
  }

  @Test
  func `register should replace an existing registration for the same id`() throws {
    nonisolated(unsafe) var savedValue: [String: Any]?
    nonisolated(unsafe) var registerCalls = 0
    nonisolated(unsafe) var unregisteredRef: EventHotKeyRef?

    let firstHotKey = HotKey(key: .a, modifiers: [.command])
    let secondHotKey = HotKey(key: .b, modifiers: [.command, .shift])
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { value, _ in savedValue = value as? [String: Any] }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in
        registerCalls += 1
        return (OpaquePointer(bitPattern: registerCalls + 200), noErr)
      }
      $0.carbonEventsCoreClient.unregisterEventHotKey = {
        unregisteredRef = $0
        return noErr
      }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: firstHotKey, id: 1)
    let firstRef = try #require(sut.activeRegistrations[1]?.ref)
    sut.register(hotKey: secondHotKey, id: 1)

    let registration = try #require(sut.activeRegistrations[1])
    let savedHotKey = try #require(savedValue?["1"] as? [String: Int])
    #expect(unregisteredRef == firstRef)
    #expect(registration.hotKey == secondHotKey)
    #expect(registration.ref != firstRef)
    #expect(savedHotKey[String.DEFAULTS_KEY_CODE_KEY] == secondHotKey.key.keyCode)
    #expect(savedHotKey[String.DEFAULTS_MODIFIERS_KEY] == secondHotKey.modifiers.carbon)
  }

  @Test
  func `register should record user conflicts for different ids`() {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in (mockEventHotKeyRef, noErr) }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: hotKey, id: 1)
    sut.register(hotKey: hotKey, id: 2)

    #expect(sut.hotKeyStatuses[1] == .registered(hotKey))
    #expect(sut.hotKeyStatuses[2] == .failedToRegister(hotKey: hotKey, error: .userConflict))
    #expect(sut.activeRegistrations[1]?.hotKey == hotKey)
    #expect(sut.activeRegistrations[2] == nil)
  }

  @Test
  func `register without an event dispatcher target should record unknown error`() {
    let hotKey = HotKey(key: .a, modifiers: [.command])

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { nil }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: hotKey, id: 1)

    #expect(sut.hotKeyStatuses[1] == .failedToRegister(hotKey: hotKey, error: .unknown))
    #expect(sut.activeRegistrations[1] == nil)
  }

  @Test
  func `register, with unexpected Carbon failure, should record unknown error`() {
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in
        (nil, OSStatus(eventInternalErr))
      }
    } operation: {
      HotKeyManager()
    }

    let hotKey = HotKey(key: .a, modifiers: [.command])
    sut.register(hotKey: hotKey, id: 1)

    #expect(sut.hotKeyStatuses[1] == .failedToRegister(hotKey: hotKey, error: .unknown))
    #expect(sut.activeRegistrations[1] == nil)
  }

  @Test
  func `stop, when not resumed, should do nothing`() {
    nonisolated(unsafe) var unregisterCalls = 0

    let sut = withDependencies {
      $0.carbonEventsCoreClient.unregisterEventHotKey = { _ in
        unregisterCalls += 1
        return noErr
      }
    } operation: {
      HotKeyManager()
    }

    sut.stop()

    #expect(unregisterCalls == 0)
    #expect(!sut.isResumed)
    #expect(sut.activeRegistrations.isEmpty)
  }

  @Test
  func `register should surface carbon duplicate failures for the same id`() throws {
    nonisolated(unsafe) var unregisteredRef: EventHotKeyRef?

    let firstHotKey = HotKey(key: .a, modifiers: [.command])
    let secondHotKey = HotKey(key: .b, modifiers: [.command])
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = { keyCode, _, _, _, _ in
        if keyCode == UInt32(firstHotKey.key.keyCode) {
          return (mockEventHotKeyRef, noErr)
        }
        return (nil, OSStatus(eventHotKeyExistsErr))
      }
      $0.carbonEventsCoreClient.unregisterEventHotKey = {
        unregisteredRef = $0
        return noErr
      }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: firstHotKey, id: 1)
    let firstRef = try #require(sut.activeRegistrations[1]?.ref)
    sut.register(hotKey: secondHotKey, id: 1)

    #expect(unregisteredRef == firstRef)
    #expect(sut.hotKeyStatuses[1] == .failedToRegister(hotKey: secondHotKey, error: .carbonHotKeyExists))
    #expect(sut.activeRegistrations[1] == nil)
  }

  @Test
  func `unregister should clear stored and active hot key`() {
    nonisolated(unsafe) var savedValue: [String: Any]?
    nonisolated(unsafe) var unregisteredRef: EventHotKeyRef?

    let hotKey = HotKey(key: .a, modifiers: [.command])
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in
        [
          "1": [
            String.DEFAULTS_KEY_CODE_KEY: hotKey.key.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: hotKey.modifiers.carbon,
          ]
        ]
      }
      $0.userDefaultsClient.setAny = { value, _ in savedValue = value as? [String: Any] }
      $0.carbonEventsCoreClient.unregisterEventHotKey = {
        unregisteredRef = $0
        return noErr
      }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in (mockEventHotKeyRef, noErr) }
    } operation: {
      HotKeyManager()
    }

    sut.register(hotKey: hotKey, id: 1)
    sut.unregister(id: 1)

    #expect(savedValue?.isEmpty == true)
    #expect(unregisteredRef == mockEventHotKeyRef)
    #expect(sut.activeRegistrations.isEmpty)
    #expect(sut.hotKeyStatuses.isEmpty)
    #expect(sut.eventHandlerRef == nil)
    #expect(!sut.isResumed)
  }

  @Test
  func `unregister without an active registration should still clear persisted state`() {
    nonisolated(unsafe) var savedValue: [String: Any]?
    nonisolated(unsafe) var unregisterCalls = 0

    let hotKey = HotKey(key: .a, modifiers: [.command])
    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in
        [
          "1": [
            String.DEFAULTS_KEY_CODE_KEY: hotKey.key.keyCode,
            String.DEFAULTS_MODIFIERS_KEY: hotKey.modifiers.carbon,
          ]
        ]
      }
      $0.userDefaultsClient.setAny = { value, _ in savedValue = value as? [String: Any] }
      $0.carbonEventsCoreClient.unregisterEventHotKey = { _ in
        unregisterCalls += 1
        return noErr
      }
    } operation: {
      HotKeyManager()
    }

    sut.unregister(id: 1)

    #expect(savedValue?.isEmpty == true)
    #expect(unregisterCalls == 0)
    #expect(sut.status(of: 1) == nil)
  }

  @Test
  func `presses should route through the boxed callback`() async throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?
    nonisolated(unsafe) var inName: EventParamName?
    nonisolated(unsafe) var inDesiredType: EventParamType?
    nonisolated(unsafe) var inBufferSize: Int?
    nonisolated(unsafe) var outActualTypeWasNil = false
    nonisolated(unsafe) var outActualSizeWasNil = false

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in (mockEventHotKeyRef, noErr) }
      $0.carbonEventsCoreClient.getEventParameter = {
        _,
          receivedInName,
          receivedDesiredType,
          receivedOutActualType,
          receivedBufferSize,
          receivedOutActualSize,
          outData in
        inName = receivedInName
        inDesiredType = receivedDesiredType
        inBufferSize = receivedBufferSize
        outActualTypeWasNil = receivedOutActualType == nil
        outActualSizeWasNil = receivedOutActualSize == nil
        outData?.assumingMemoryBound(to: EventHotKeyID.self).pointee = .init(
          signature: .HOT_KEY_SIGNATURE,
          id: 1,
        )
        return noErr
      }
      $0.carbonEventsCoreClient.getEventKind = { _ in UInt32(kEventHotKeyPressed) }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    sut.register(hotKey: .init(key: .a, modifiers: [.command]), id: 1)

    var iterator = sut.presses(of: 1).makeAsyncIterator()
    let status = try #require(box).callback(OpaquePointer(bitPattern: 0x4))

    #expect(status == noErr)
    #expect(await iterator.next() == .keyDown)
    #expect(inName == UInt32(kEventParamDirectObject))
    #expect(inDesiredType == UInt32(typeEventHotKeyID))
    #expect(inBufferSize == MemoryLayout<EventHotKeyID>.size)
    #expect(outActualTypeWasNil)
    #expect(outActualSizeWasNil)
  }

  @Test
  func `presses should route key up events through the boxed callback`() async throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in (mockEventHotKeyRef, noErr) }
      $0.carbonEventsCoreClient.getEventParameter = { _, _, _, _, _, _, outData in
        outData?.assumingMemoryBound(to: EventHotKeyID.self).pointee = .init(
          signature: .HOT_KEY_SIGNATURE,
          id: 1,
        )
        return noErr
      }
      $0.carbonEventsCoreClient.getEventKind = { _ in UInt32(kEventHotKeyReleased) }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    sut.register(hotKey: .init(key: .a, modifiers: [.command]), id: 1)

    var iterator = sut.presses(of: 1).makeAsyncIterator()
    let status = try #require(box).callback(OpaquePointer(bitPattern: 0x5))

    #expect(status == noErr)
    #expect(await iterator.next() == .keyUp)
  }

  @Test
  func `presses should start repeating key down until key up`() async throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?
    nonisolated(unsafe) var eventKind = UInt32(kEventHotKeyPressed)

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.registerEventHotKey = { _, _, _, _, _ in (mockEventHotKeyRef, noErr) }
      $0.carbonEventsCoreClient.getEventParameter = { _, _, _, _, _, _, outData in
        outData?.assumingMemoryBound(to: EventHotKeyID.self).pointee = .init(
          signature: .HOT_KEY_SIGNATURE,
          id: 1,
        )
        return noErr
      }
      $0.carbonEventsCoreClient.getEventKind = { _ in eventKind }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    sut.register(hotKey: .init(key: .a, modifiers: [.command]), id: 1)

    var iterator = sut.presses(of: 1).makeAsyncIterator()
    let status = try #require(box).callback(OpaquePointer(bitPattern: 0x6))

    #expect(status == noErr)
    #expect(await iterator.next() == .keyDown)
    #expect(sut.eventHotKeyTask != nil)

    eventKind = UInt32(kEventHotKeyReleased)
    let keyUpStatus = try #require(box).callback(OpaquePointer(bitPattern: 0x7))
    #expect(keyUpStatus == noErr)
    #expect(await iterator.next() == .keyUp)
    #expect(sut.eventHotKeyTask == nil)
  }

  @Test
  func `presses, with nil event, should return eventNotHandledErr`() throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    let status = try #require(box).callback(nil)

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test
  func `presses, with getEventParameter error, should return eventNotHandledErr`() throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.getEventParameter = { _, _, _, _, _, _, outData in
        outData?.assumingMemoryBound(to: EventHotKeyID.self).pointee = .init(
          signature: .HOT_KEY_SIGNATURE,
          id: 1,
        )
        return OSStatus(eventInternalErr)
      }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    _ = sut.presses(of: 1)
    let status = try #require(box).callback(OpaquePointer(bitPattern: 0x7))

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test
  func `presses, with no active registration for the handler id, should return eventNotHandledErr`() throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.getEventParameter = { _, _, _, _, _, _, outData in
        outData?.assumingMemoryBound(to: EventHotKeyID.self).pointee = .init(
          signature: .HOT_KEY_SIGNATURE,
          id: 1,
        )
        return noErr
      }
      $0.carbonEventsCoreClient.getEventKind = { _ in UInt32(kEventHotKeyPressed) }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    _ = sut.presses(of: 1)
    let status = try #require(box).callback(OpaquePointer(bitPattern: 0x8))

    #expect(status == OSStatus(eventNotHandledErr))
  }

  @Test
  func `presses should ignore events with an unexpected signature`() throws {
    nonisolated(unsafe) var box: BoxedHotKeyHandler?

    let sut = withDependencies {
      $0.userDefaultsClient.dictionary = { _ in nil }
      $0.userDefaultsClient.setAny = { _, _ in }
      $0.carbonEventsCoreClient.getEventDispatcherTarget = { mockEventDispatcherTarget }
      $0.carbonEventsCoreClient.installEventHandler = { _, _, _, receivedBox in
        box = receivedBox
        return (mockEventHandlerRef, noErr)
      }
      $0.carbonEventsCoreClient.getEventParameter = { _, _, _, _, _, _, outData in
        outData?.assumingMemoryBound(to: EventHotKeyID.self).pointee = .init(
          signature: 0,
          id: 1,
        )
        return noErr
      }
      $0.carbonEventsCoreClient.getEventKind = { _ in UInt32(kEventHotKeyPressed) }
    } operation: {
      HotKeyManager()
    }

    sut.start()
    let status = try #require(box).callback(OpaquePointer(bitPattern: 0x6))

    #expect(status == OSStatus(eventNotHandledErr))
  }
}

let mockEventDispatcherTarget = OpaquePointer(bitPattern: 0x1)
let mockEventHandlerRef = OpaquePointer(bitPattern: 0x2)
let mockEventHotKeyRef = OpaquePointer(bitPattern: 0x3)
