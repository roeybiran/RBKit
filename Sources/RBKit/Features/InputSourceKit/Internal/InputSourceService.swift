@preconcurrency import Carbon
import Dependencies
import Foundation
import Sharing

@MainActor
final class InputSourceService<Client: TextInputSourcesClientProtocol> {

  // MARK: Lifecycle

  init(textInputSourcesClient: Client) {
    self.textInputSourcesClient = textInputSourcesClient
  }

  // MARK: Internal

  typealias InputSourceList = [InputSource.ID: (ref: Client.InputSourceRef, value: InputSource)]
  typealias Stream = AsyncStream<[InputSource]>

  func start() -> Stream {
    isRunning = true

    let (stream, continuation) = Stream.makeStream()

    updateAllSources()
    continuation.yield(sortedInputSources())

    let task = Task { [weak self] in
      guard let self else { return }
      let notification = Notification.Name(kTISNotifyEnabledKeyboardInputSourcesChanged as String)
      for await _ in distributedNotificationCenterClient.notifications(named: notification) {
        updateAllSources()
        continuation.yield(sortedInputSources())
      }
    }

    continuation.onTermination = { _ in
      task.cancel()
    }

    return stream
  }

  func getPreferredInputSource() -> InputSource? {
    assert(isRunning, "Call start() first.")

    guard let preferredInputSourceID else { return nil }
    return inputSourceList[preferredInputSourceID]?.value
  }

  func setPreferredInputSource(_ source: InputSource?) {
    assert(isRunning, "Call start() first.")

    $preferredInputSourceID.withLock { $0 = source?.id }
  }

  func activatePreferredSource() {
    assert(isRunning, "Call start() first.")

    guard
      let preferredInputSourceID,
      let preferredInputSourceRef = inputSourceList[preferredInputSourceID]?.ref
    else {
      previousInputSourceID = nil
      return
    }

    let currentInputSourceID: InputSource.ID? =
      if
        let currentInputSourceRef = textInputSourcesClient.TISCopyCurrentKeyboardInputSource()?
          .takeRetainedValue()
      {
        getInputSourceID(ref: currentInputSourceRef)
      } else {
        nil
      }
    if currentInputSourceID == preferredInputSourceID {
      previousInputSourceID = nil
      return
    }

    previousInputSourceID = currentInputSourceID
    _ = textInputSourcesClient.TISSelectInputSource(preferredInputSourceRef)
  }

  func restorePreviousSource() {
    assert(isRunning, "Call start() first.")

    defer { previousInputSourceID = nil }

    guard
      preferredInputSourceID != nil,
      let previousInputSourceID,
      let previousInputSourceRef = inputSourceList[previousInputSourceID]
    else { return }

    _ = textInputSourcesClient.TISSelectInputSource(previousInputSourceRef.ref)
  }

  // MARK: Private

  @Dependency(\.distributedNotificationCenterClient) private var distributedNotificationCenterClient
  @Shared(.preferredInputSourceID) private var preferredInputSourceID: InputSource.ID?

  private let textInputSourcesClient: Client

  private var isRunning = false
  private var previousInputSourceID: InputSource.ID?
  private var inputSourceList = InputSourceList()

  private func updateAllSources() {
    let properties: [CFString: CFTypeRef] = [
      kTISPropertyInputSourceIsEnabled: kCFBooleanTrue,
      kTISPropertyInputSourceIsSelectCapable: kCFBooleanTrue,
      kTISPropertyInputSourceType: kTISTypeKeyboardLayout,
      kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource,
    ]
    let includeAllInstalled = false
    let inputSourceRefs = textInputSourcesClient
      .TISCreateInputSourceList(properties as CFDictionary, includeAllInstalled)?
      .takeRetainedValue() as? [Client.InputSourceRef] ?? []

    inputSourceList = inputSourceRefs.reduce(into: InputSourceList()) { list, inputSourceRef in
      guard
        let id = getInputSourceID(ref: inputSourceRef),
        let name: String = sourceProperty(inputSourceRef, key: kTISPropertyLocalizedName)
      else {
        return
      }
      let inputSourceValue = InputSource(id: id, name: name)
      list[id] = (inputSourceRef, inputSourceValue)
    }

    if let preferredInputSourceID, inputSourceList[preferredInputSourceID] == nil {
      $preferredInputSourceID.withLock { $0 = nil }
      previousInputSourceID = nil
    }
  }

  private func getInputSourceID(ref: Client.InputSourceRef) -> String? {
    sourceProperty(ref, key: kTISPropertyInputSourceID)
  }

  private func sortedInputSources() -> [InputSource] {
    inputSourceList.values.map(\.value).sorted { $0.name < $1.name }
  }

  private func sourceProperty<T>(_ inputSourceRef: Client.InputSourceRef, key: CFString) -> T? {
    guard
      let rawPropertyValue = textInputSourcesClient.TISGetInputSourceProperty(inputSourceRef, key)
    else {
      return nil
    }

    return Unmanaged<AnyObject>.fromOpaque(rawPropertyValue).takeUnretainedValue() as? T
  }

}
