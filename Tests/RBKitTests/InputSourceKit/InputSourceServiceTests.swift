@preconcurrency import Carbon
import Dependencies
import Foundation
import Sharing
import Testing
@preconcurrency @testable import RBKit

// MARK: - InputSourceServiceTests

@MainActor
struct InputSourceServiceTests {

  @Test
  func `start, should emit sorted sources`() async throws {
    let sourceB = InputSource(id: "b", name: "B")
    let sourceA = InputSource(id: "a", name: "A")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceB, sourceA], currentSourceID: nil)

    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    var observer = sut.start().makeAsyncIterator()
    let result = try #require(await observer.next())

    #expect(result == [sourceA, sourceB])
  }

  @Test
  func `start, with matching names, should sort by name only`() async throws {
    let sourceB = InputSource(id: "b", name: "B")
    let sourceA1 = InputSource(id: "a1", name: "A")
    let sourceA2 = InputSource(id: "a2", name: "A")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceB, sourceA2, sourceA1], currentSourceID: nil)

    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    var observer = sut.start().makeAsyncIterator()
    let result = try #require(await observer.next())

    #expect(result.map(\.name) == ["A", "A", "B"])
    #expect(Set(result.map(\.id)) == Set([sourceA1.id, sourceA2.id, sourceB.id]))
  }

  @Test
  func `start, with enabled keyboard input sources changed notification, should emit initial and updated snapshots`(
  ) async throws {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let sourceRefByID: [String: TextInputSourceMock] = [
      sourceA.id: TextInputSourceMock(),
      sourceB.id: TextInputSourceMock(),
    ]
    nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = Dictionary(
      uniqueKeysWithValues: [sourceA, sourceB].compactMap { source in
        if let sourceRef = sourceRefByID[source.id] {
          (
            ObjectIdentifier(sourceRef),
            [
              kTISPropertyInputSourceID: source.id as NSString,
              kTISPropertyLocalizedName: source.name as NSString,
            ],
          )
        } else {
          nil
        }
      }
    )
    let installedSourceIDs = MutableValue([sourceA.id])
    nonisolated(unsafe) var createInputSourceListCallCount = 0

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      createInputSourceListCallCount += 1
      let sourceRefs = installedSourceIDs.value.compactMap { sourceRefByID[$0] }
      return Unmanaged.passRetained(sourceRefs as CFArray)
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
      } else {
        nil
      }
    }

    let notificationCenter = NotificationCenter()
    let distributedNotificationCenterClient = DistributedNotificationCenterClient(
      notifications: { named in
        notificationCenter.notifications(named: named, object: nil)
      }
    )
    let sut = makeService(
      textInputSourcesClient: textInputSourcesClient,
      distributedNotificationCenterClient: distributedNotificationCenterClient,
    )
    var observer = sut.start().makeAsyncIterator()

    #expect(await observer.next() == [sourceA])
    #expect(createInputSourceListCallCount == 1)
    try await Task.sleep(for: notificationPropagationDelay)

    installedSourceIDs.value = [sourceB.id, sourceA.id]
    notificationCenter.post(
      name: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String),
      object: nil,
    )
    try await Task.sleep(for: notificationPropagationDelay)

    #expect(createInputSourceListCallCount == 2)
    #expect(await observer.next() == [sourceA, sourceB])
  }

  @Test
  func `start, with unchanged refresh, should emit duplicate snapshots`() async throws {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceRefByID: [String: TextInputSourceMock] = [
      sourceA.id: TextInputSourceMock()
    ]
    nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = Dictionary(
      uniqueKeysWithValues: [sourceA].compactMap { source in
        if let sourceRef = sourceRefByID[source.id] {
          (
            ObjectIdentifier(sourceRef),
            [
              kTISPropertyInputSourceID: source.id as NSString,
              kTISPropertyLocalizedName: source.name as NSString,
            ],
          )
        } else {
          nil
        }
      }
    )
    let installedSourceIDs = [sourceA.id]
    nonisolated(unsafe) var createInputSourceListCallCount = 0

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      createInputSourceListCallCount += 1
      let sourceRefs = installedSourceIDs.compactMap { sourceRefByID[$0] }
      return Unmanaged.passRetained(sourceRefs as CFArray)
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
      } else {
        nil
      }
    }

    let notificationCenter = NotificationCenter()
    let distributedNotificationCenterClient = DistributedNotificationCenterClient(
      notifications: { named in
        notificationCenter.notifications(named: named, object: nil)
      }
    )
    let sut = makeService(
      textInputSourcesClient: textInputSourcesClient,
      distributedNotificationCenterClient: distributedNotificationCenterClient,
    )
    var observer = sut.start().makeAsyncIterator()

    #expect(await observer.next() == [sourceA])
    #expect(createInputSourceListCallCount == 1)
    try await Task.sleep(for: notificationPropagationDelay)

    notificationCenter.post(
      name: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String),
      object: nil,
    )
    try await Task.sleep(for: notificationPropagationDelay)
    #expect(createInputSourceListCallCount == 2)

    #expect(await observer.next() == [sourceA])
  }

  @Test
  func `start, with multiple subscribers, should emit updates to all streams`() async throws {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let sourceRefByID: [String: TextInputSourceMock] = [
      sourceA.id: TextInputSourceMock(),
      sourceB.id: TextInputSourceMock(),
    ]
    nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = Dictionary(
      uniqueKeysWithValues: [sourceA, sourceB].compactMap { source in
        if let sourceRef = sourceRefByID[source.id] {
          (
            ObjectIdentifier(sourceRef),
            [
              kTISPropertyInputSourceID: source.id as NSString,
              kTISPropertyLocalizedName: source.name as NSString,
            ],
          )
        } else {
          nil
        }
      }
    )
    let installedSourceIDs = MutableValue([sourceA.id])

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      let sourceRefs = installedSourceIDs.value.compactMap { sourceRefByID[$0] }
      return Unmanaged.passRetained(sourceRefs as CFArray)
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
      } else {
        nil
      }
    }

    let notificationCenter = NotificationCenter()
    let distributedNotificationCenterClient = DistributedNotificationCenterClient(
      notifications: { named in
        notificationCenter.notifications(named: named, object: nil)
      }
    )
    let sut = makeService(
      textInputSourcesClient: textInputSourcesClient,
      distributedNotificationCenterClient: distributedNotificationCenterClient,
    )
    var firstObserver = sut.start().makeAsyncIterator()
    #expect(await firstObserver.next() == [sourceA])
    var secondObserver = sut.start().makeAsyncIterator()
    #expect(await secondObserver.next() == [sourceA])

    installedSourceIDs.value = [sourceB.id, sourceA.id]
    notificationCenter.post(
      name: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String),
      object: nil,
    )
    try await Task.sleep(for: notificationPropagationDelay)

    #expect(await firstObserver.next() == [sourceA, sourceB])
    #expect(await secondObserver.next() == [sourceA, sourceB])
  }

  @Test
  func `getPreferredInputSource, with no preferred source ID, should return nil`() {
    let sourceA = InputSource(id: "a", name: "A")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceA], currentSourceID: nil)

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = nil
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    #expect(sut.getPreferredInputSource() == nil)
  }

  @Test
  func `getPreferredInputSource, with preferred source ID, should return matching source`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceA, sourceB], currentSourceID: nil)

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = "b"
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    #expect(sut.getPreferredInputSource() == sourceB)
  }

  @Test
  func `updateAllSources, with non-installed preferred source ID, should clear persisted preferred source ID`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceA], currentSourceID: nil)

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    #expect(preferredInputSourceID == nil)
    #expect(sut.getPreferredInputSource() == nil)
  }

  @Test
  func `setPreferredInputSource, should persist selected source ID and nil`() {
    let sourceA = InputSource(id: "a", name: "A")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceA], currentSourceID: nil)

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = nil
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.setPreferredInputSource(sourceA)
    #expect(preferredInputSourceID == "a")

    sut.setPreferredInputSource(nil)
    #expect(preferredInputSourceID == nil)
  }

  @Test
  func `activatePreferredSource, should switch to preferred input source`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: sourceB.id,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = "a"
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()

    #expect(selectedSourceIDs == ["a"])
  }

  @Test
  func `activatePreferredSource, with nil current source, should not set previous source`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: nil,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id])
  }

  @Test
  func `activatePreferredSource, with missing preferred source ID, should do nothing`() {
    let sourceA = InputSource(id: "a", name: "A")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceA], currentSourceID: nil)

    nonisolated(unsafe) var callCount = 0
    textInputSourcesClient.TISSelectInputSourceHandler = { _ in
      callCount += 1
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = nil
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()

    #expect(callCount == 0)
  }

  @Test
  func `activatePreferredSource, with non-installed preferred source ID, should do nothing`() {
    let sourceA = InputSource(id: "a", name: "A")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [], currentSourceID: nil)

    nonisolated(unsafe) var callCount = 0
    textInputSourcesClient.TISSelectInputSourceHandler = { _ in
      callCount += 1
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceA.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()

    #expect(callCount == 0)
  }

  @Test
  func `activatePreferredSource, when already on preferred source, should clear previous source`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: sourceA.id,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var currentSourceID: String? = sourceA.id
    textInputSourcesClient.TISCopyCurrentKeyboardInputSourceHandler = {
      guard let currentSourceID, let sourceRef = sourceRefByID[currentSourceID] else { return nil }
      return Unmanaged.passRetained(sourceRef)
    }

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
        currentSourceID = sourceID
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()
    sut.activatePreferredSource()
    sut.setPreferredInputSource(sourceA)
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id])
  }

  @Test
  func `restorePreviousSource, should restore previous source ID`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: sourceA.id,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id, sourceA.id])
  }

  @Test
  func `restorePreviousSource, after successful restore, should clear previous source`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: sourceA.id,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()
    sut.restorePreviousSource()
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id, sourceA.id])
  }

  @Test
  func `restorePreviousSource, with previous source missing from all sources, should do nothing`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let sourceRefA = TextInputSourceMock()
    let sourceRefB = TextInputSourceMock()
    let currentSourceRef = TextInputSourceMock()
    let sourceIDByRef: [ObjectIdentifier: String] = [
      ObjectIdentifier(sourceRefA): sourceA.id,
      ObjectIdentifier(sourceRefB): sourceB.id,
      ObjectIdentifier(currentSourceRef): "missing",
    ]
    let sourceNameByRef: [ObjectIdentifier: String] = [
      ObjectIdentifier(sourceRefA): sourceA.name,
      ObjectIdentifier(sourceRefB): sourceB.name,
      ObjectIdentifier(currentSourceRef): "Missing",
    ]

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      Unmanaged.passRetained([sourceRefA, sourceRefB] as CFArray)
    }
    textInputSourcesClient.TISCopyCurrentKeyboardInputSourceHandler = {
      Unmanaged.passRetained(currentSourceRef)
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if
        propertyKey == kTISPropertyInputSourceID,
        let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)]
      {
        return UnsafeMutableRawPointer(Unmanaged.passUnretained(sourceID as NSString).toOpaque())
      }
      if
        propertyKey == kTISPropertyLocalizedName,
        let sourceName = sourceNameByRef[ObjectIdentifier(inputSource)]
      {
        return UnsafeMutableRawPointer(Unmanaged.passUnretained(sourceName as NSString).toOpaque())
      }
      return nil
    }

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id])
  }

  @Test
  func `restorePreviousSource, with nil preferred source ID, should do nothing`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: sourceA.id,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    _ = sut.start()
    sut.activatePreferredSource()
    sut.setPreferredInputSource(nil)
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id])
  }

  @Test
  func `enabled keyboard input sources changed notification, should refresh all sources`() async throws {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let sourceRefByID: [String: TextInputSourceMock] = [
      sourceA.id: TextInputSourceMock(),
      sourceB.id: TextInputSourceMock(),
    ]
    nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = Dictionary(
      uniqueKeysWithValues: [sourceA, sourceB].compactMap { source in
        if let sourceRef = sourceRefByID[source.id] {
          (
            ObjectIdentifier(sourceRef),
            [
              kTISPropertyInputSourceID: source.id as NSString,
              kTISPropertyLocalizedName: source.name as NSString,
            ],
          )
        } else {
          nil
        }
      }
    )
    let installedSourceIDs = MutableValue([sourceA.id])
    nonisolated(unsafe) var createInputSourceListCallCount = 0

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      createInputSourceListCallCount += 1
      let sourceRefs = installedSourceIDs.value.compactMap { sourceRefByID[$0] }
      return Unmanaged.passRetained(sourceRefs as CFArray)
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
      } else {
        nil
      }
    }

    let notificationCenter = NotificationCenter()
    let distributedNotificationCenterClient = DistributedNotificationCenterClient(
      notifications: { named in
        notificationCenter.notifications(named: named, object: nil)
      }
    )
    let sut = makeService(
      textInputSourcesClient: textInputSourcesClient,
      distributedNotificationCenterClient: distributedNotificationCenterClient,
    )
    var observer = sut.start().makeAsyncIterator()

    #expect(await observer.next() == [sourceA])
    #expect(createInputSourceListCallCount == 1)
    try await Task.sleep(for: notificationPropagationDelay)

    installedSourceIDs.value = [sourceB.id, sourceA.id]
    notificationCenter.post(
      name: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String),
      object: nil,
    )
    try await Task.sleep(for: notificationPropagationDelay)

    #expect(createInputSourceListCallCount == 2)
    #expect(await observer.next() == [sourceA, sourceB])
  }

  @Test
  func `enabled keyboard input sources changed notification, with preferred source removed, should clear persisted preferred source ID`(
  ) async throws {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let sourceRefByID: [String: TextInputSourceMock] = [
      sourceA.id: TextInputSourceMock(),
      sourceB.id: TextInputSourceMock(),
    ]
    nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = Dictionary(
      uniqueKeysWithValues: [sourceA, sourceB].compactMap { source in
        if let sourceRef = sourceRefByID[source.id] {
          (
            ObjectIdentifier(sourceRef),
            [
              kTISPropertyInputSourceID: source.id as NSString,
              kTISPropertyLocalizedName: source.name as NSString,
            ],
          )
        } else {
          nil
        }
      }
    )
    let installedSourceIDs = MutableValue([sourceA.id, sourceB.id])
    nonisolated(unsafe) var createInputSourceListCallCount = 0

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      createInputSourceListCallCount += 1
      let sourceRefs = installedSourceIDs.value.compactMap { sourceRefByID[$0] }
      return Unmanaged.passRetained(sourceRefs as CFArray)
    }
    textInputSourcesClient.TISCopyCurrentKeyboardInputSourceHandler = {
      if let sourceRef = sourceRefByID[sourceA.id] {
        Unmanaged.passRetained(sourceRef)
      } else {
        nil
      }
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
      } else {
        nil
      }
    }
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })
    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }
      return noErr
    }

    let notificationCenter = NotificationCenter()
    let distributedNotificationCenterClient = DistributedNotificationCenterClient(
      notifications: { named in
        notificationCenter.notifications(named: named, object: nil)
      }
    )
    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let sut = makeService(
      textInputSourcesClient: textInputSourcesClient,
      distributedNotificationCenterClient: distributedNotificationCenterClient,
    )
    var observer = sut.start().makeAsyncIterator()

    #expect(await observer.next() == [sourceA, sourceB])
    #expect(createInputSourceListCallCount == 1)
    #expect(preferredInputSourceID == sourceB.id)

    sut.activatePreferredSource()
    #expect(selectedSourceIDs == [sourceB.id])

    try await Task.sleep(for: notificationPropagationDelay)

    installedSourceIDs.value = [sourceA.id]
    notificationCenter.post(
      name: Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String),
      object: nil,
    )
    try await Task.sleep(for: notificationPropagationDelay)

    #expect(createInputSourceListCallCount == 2)
    #expect(await observer.next() == [sourceA])
    #expect(preferredInputSourceID == nil)
    #expect(sut.getPreferredInputSource() == nil)

    sut.setPreferredInputSource(sourceA)
    sut.restorePreviousSource()
    #expect(selectedSourceIDs == [sourceB.id])
  }

  @Test
  func `updateAllSources, with invalid source properties, should skip invalid entries`() async throws {
    let validSource = InputSource(id: "valid", name: "Valid")
    let sourceRefValid = TextInputSourceMock()
    let sourceRefMissingID = TextInputSourceMock()
    let sourceRefMissingName = TextInputSourceMock()
    nonisolated(unsafe) let propertiesBySourceRef: [ObjectIdentifier: [CFString: AnyObject]] = [
      ObjectIdentifier(sourceRefValid): [
        kTISPropertyInputSourceID: validSource.id as NSString,
        kTISPropertyLocalizedName: validSource.name as NSString,
      ],
      ObjectIdentifier(sourceRefMissingID): [
        kTISPropertyLocalizedName: "No ID" as NSString
      ],
      ObjectIdentifier(sourceRefMissingName): [
        kTISPropertyInputSourceID: "missing-name" as NSString
      ],
    ]

    let textInputSourcesClient = TextInputSourcesClientMock()
    textInputSourcesClient.TISCreateInputSourceListHandler = { _, _ in
      Unmanaged.passRetained([sourceRefMissingID, sourceRefValid, sourceRefMissingName] as CFArray)
    }
    textInputSourcesClient.TISGetInputSourcePropertyHandler = { inputSource, propertyKey in
      if let propertyValue = propertiesBySourceRef[ObjectIdentifier(inputSource)]?[propertyKey] {
        UnsafeMutableRawPointer(Unmanaged.passUnretained(propertyValue).toOpaque())
      } else {
        nil
      }
    }

    let sut = makeService(textInputSourcesClient: textInputSourcesClient)
    var observer = sut.start().makeAsyncIterator()

    #expect(try #require(await observer.next()) == [validSource])
  }
}

private let notificationPropagationDelay = Duration.milliseconds(50)

// MARK: - MutableValue

// Test-only mutable box is configured and consumed within these tests but must cross @Sendable closures.
// swiftlint:disable:next no_unchecked_sendable
private final class MutableValue<Value>: @unchecked Sendable {

  // MARK: Lifecycle

  init(_ value: Value) {
    self.value = value
  }

  // MARK: Internal

  var value: Value
}
