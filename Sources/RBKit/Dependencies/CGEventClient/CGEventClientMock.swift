import Carbon
import os

public final class CGEventClientMock: CGEventClientProtocol {

  // MARK: Lifecycle

  public nonisolated init() { }

  // MARK: Public

  public typealias MachPort = MachPortMock

  public var _createEventTap: @Sendable (
    _ tap: CGEventTapLocation,
    _ place: CGEventTapPlacement,
    _ options: CGEventTapOptions,
    _ eventsOfInterest: CGEventMask,
    _ userInfo: UnsafeMutableRawPointer?,
  ) -> MachPortMock? {
    get { state.withLock { $0.createEventTap } }
    set { state.withLock { $0.createEventTap = newValue } }
  }

  public var _getEnabled: @Sendable (_ tap: MachPortMock) -> Bool {
    get { state.withLock { $0.getEnabled } }
    set { state.withLock { $0.getEnabled = newValue } }
  }

  public var _setEnabled: @Sendable (_ tap: MachPortMock, _ isEnabled: Bool) -> Void {
    get { state.withLock { $0.setEnabled } }
    set { state.withLock { $0.setEnabled = newValue } }
  }

  public var _flags: @Sendable (_ event: CGEvent) -> CGEventFlags {
    get { state.withLock { $0.flags } }
    set { state.withLock { $0.flags = newValue } }
  }

  public var _getIntegerValue: @Sendable (_ event: CGEvent, _ field: CGEventField) -> Int64 {
    get { state.withLock { $0.getIntegerValue } }
    set { state.withLock { $0.getIntegerValue = newValue } }
  }

  public var _post: @Sendable (_ event: CGEvent, _ tap: CGEventTapLocation) -> Void {
    get { state.withLock { $0.post } }
    set { state.withLock { $0.post = newValue } }
  }

  public var _postToPid: @Sendable (_ event: CGEvent, _ pid: pid_t) -> Void {
    get { state.withLock { $0.postToPid } }
    set { state.withLock { $0.postToPid = newValue } }
  }

  public func createEventTap(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    userInfo: UnsafeMutableRawPointer?,
  ) -> MachPortMock? {
    _createEventTap(tap, place, options, eventsOfInterest, userInfo)
  }

  public func getEnabled(tap: MachPortMock) -> Bool {
    _getEnabled(tap)
  }

  public func setEnabled(tap: MachPortMock, isEnabled: Bool) {
    _setEnabled(tap, isEnabled)
  }

  public func flags(event: CGEvent) -> CGEventFlags {
    _flags(event)
  }

  public func getIntegerValue(event: CGEvent, field: CGEventField) -> Int64 {
    _getIntegerValue(event, field)
  }

  public func post(event: CGEvent, tap: CGEventTapLocation) {
    _post(event, tap)
  }

  public func postToPid(event: CGEvent, pid: pid_t) {
    _postToPid(event, pid)
  }

  // MARK: Private

  private struct State: Sendable {
    var createEventTap: @Sendable (
      _ tap: CGEventTapLocation,
      _ place: CGEventTapPlacement,
      _ options: CGEventTapOptions,
      _ eventsOfInterest: CGEventMask,
      _ userInfo: UnsafeMutableRawPointer?,
    ) -> MachPortMock? = { _, _, _, _, _ in nil }
    var getEnabled: @Sendable (_ tap: MachPortMock) -> Bool = { _ in false }
    var setEnabled: @Sendable (_ tap: MachPortMock, _ isEnabled: Bool) -> Void = { _, _ in }
    var flags: @Sendable (_ event: CGEvent) -> CGEventFlags = { _ in [] }
    var getIntegerValue: @Sendable (_ event: CGEvent, _ field: CGEventField) -> Int64 = { _, _ in 0 }
    var post: @Sendable (_ event: CGEvent, _ tap: CGEventTapLocation) -> Void = { _, _ in }
    var postToPid: @Sendable (_ event: CGEvent, _ pid: pid_t) -> Void = { _, _ in }
  }

  private let state = OSAllocatedUnfairLock(initialState: State())

}
