// https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/pathwatcher/libpathwatcher.m#L83
// https://github.com/eonil/FSEvents

import Foundation

public typealias EventHandler = (Result<[FSEvent], FSEventStream.Error>) -> Void
public typealias FSEventAsyncStream = AsyncThrowingStream<[FSEvent], (any Error)>

// MARK: - FSEventStream

public final class FSEventStream: Sendable {

  public struct Flag: OptionSet, Sendable {
    // MARK: Lifecycle

    public init(rawValue: FSEventStreamCreateFlags) {
      self.rawValue = rawValue
    }

    init(_ value: Int) {
      rawValue = FSEventStreamCreateFlags(truncatingIfNeeded: value)
    }

    // MARK: Public

    public let rawValue: FSEventStreamCreateFlags

    public static let none = Self(kFSEventStreamCreateFlagNone)
    public static let useCFTypes = Self(kFSEventStreamCreateFlagUseCFTypes)
    public static let noDefer = Self(kFSEventStreamCreateFlagNoDefer)
    public static let watchRoot = Self(kFSEventStreamCreateFlagWatchRoot)
    public static let ignoreSelf = Self(kFSEventStreamCreateFlagIgnoreSelf)
    public static let fileEvents = Self(kFSEventStreamCreateFlagFileEvents)
    public static let markSelf = Self(kFSEventStreamCreateFlagMarkSelf)
    public static let useExtendedData = Self(kFSEventStreamCreateFlagUseExtendedData)
    public static let fullHistory = Self(kFSEventStreamCreateFlagFullHistory)
  }

  public enum Error: Swift.Error, Equatable {
    case streamCreationError
    case eventPathsCastingFailure
    case numEventsMismatch
    case failedToStartStream
  }

  // MARK: Lifecycle

  /// - Throws: `streamCreationError`
  public init(
    paths: [String],
    latency: TimeInterval = 1,
    sinceWhen: FSEvent.ID = .now,
    flags: Flag = [.none],
    eventHandler: @escaping EventHandler) throws
  {
    self.eventHandler = eventHandler

    var context = FSEventStreamContext(
      version: 0,
      info: Unmanaged.passUnretained(self).toOpaque(),
      retain: nil,
      release: nil,
      copyDescription: nil)

    let callback: FSEventStreamCallback = {
      (
        _: ConstFSEventStreamRef,
        _ clientCallBackInfo: UnsafeMutableRawPointer?,
        _ numEvents: Int,
        _ eventPaths: UnsafeMutableRawPointer,
        _ eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        _ eventIds: UnsafePointer<FSEventStreamEventId>) in
      guard let clientCallbackInfo = clientCallBackInfo else {
        assertionFailure("clientCallbackInfo is nil")
        return
      }

      let stream = Unmanaged<FSEventStream>
        .fromOpaque(clientCallbackInfo)
        .takeUnretainedValue()

      guard
        let eventPaths = Unmanaged<CFArray>
          .fromOpaque(eventPaths)
          .takeUnretainedValue() as? [String]
      else {
        stream.eventHandler(.failure(.eventPathsCastingFailure))
        return
      }

      if numEvents != eventPaths.count {
        stream.eventHandler(.failure(.numEventsMismatch))
        return
      }

      var events = [FSEvent]()
      for i in 0 ..< numEvents {
        events.append(
          FSEvent(
            path: eventPaths[i],
            flag: FSEvent.Flag(rawValue: eventFlags[i]),
            id: FSEvent.ID(rawValue: eventIds[i])))
      }
      stream.eventHandler(.success(events))
    }

    if
      let streamRef = FSEventStreamCreate(
        nil,
        callback,
        &context,
        paths as CFArray,
        sinceWhen.rawValue,
        latency as CFTimeInterval,
        flags.union(.useCFTypes).rawValue)
    {
      self.streamRef = streamRef
    } else {
      throw Error.streamCreationError
    }
  }

  deinit {
    stop()
  }

  // MARK: Public

  public static func events(
    paths: [String],
    queue: DispatchQueue = DispatchQueue(label: "com.roeybiran.FSEventKit.queue", qos: .background),
    latency: TimeInterval = 1,
    sinceWhen: FSEvent.ID = .now,
    flags: Flag = [.none]) -> FSEventAsyncStream
  {
    .init { continuation in
      do {
        let eventStream = try FSEventStream(
          paths: paths,
          latency: latency,
          sinceWhen: sinceWhen,
          flags: flags)
        { result in
          switch result {
          case .success(let event):
            continuation.yield(event)
          case .failure(let error):
            continuation.finish(throwing: error)
          }
        }
        eventStream.setDispatchQueue(queue)
        try eventStream.start()
        continuation.onTermination = { _ in
          eventStream.stop()
        }
      } catch {
        continuation.finish(throwing: error)
      }
    }
  }

  public func setDispatchQueue(_ q: DispatchQueue) {
    FSEventStreamSetDispatchQueue(streamRef, q)
  }

  public func start() throws {
    if !FSEventStreamStart(streamRef) {
      throw Error.failedToStartStream
    }
  }

  public func stop() {
    FSEventStreamStop(streamRef)
  }

  // MARK: Private

  private var streamRef: FSEventStreamRef!
  private let eventHandler: EventHandler
}
