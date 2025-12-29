import Dependencies
import DependenciesMacros
import Foundation
import System

// MARK: - PathWatcherClient

@DependencyClient
public struct PathWatcherClient: Sendable {
  public var pathMonitor: @Sendable (
    _ path: FilePath,
    _ mask: DispatchSource.FileSystemEvent,
    _ queue: DispatchQueue?
  ) -> AsyncThrowingStream<DispatchSource.FileSystemEvent, any Swift.Error> = { _, _, _ in .finished() }

  public var events: @Sendable (
    _ paths: [String],
    _ latency: TimeInterval,
    _ queue: DispatchQueue?,
    _ sinceWhen: PathWatcherEvent.ID?,
    _ flags: PathWatcherFlag?
  ) -> FSEventAsyncStream = { _, _, _, _, _ in .finished() }
}

// MARK: - Type Aliases

public typealias FSEventAsyncStream = AsyncThrowingStream<[PathWatcherEvent], any Swift.Error>

// MARK: DependencyKey

extension PathWatcherClient: DependencyKey {
  public static let liveValue = Self(
    pathMonitor: { path, mask, queue in
      let fileDescriptorClient = FileDescriptorClient.liveValue
      let dispatchSourceFileSystemObjectClient = DispatchSourceFileSystemObjectClient.liveValue

      let (stream, continuation) = AsyncThrowingStream.makeStream(of: DispatchSource.FileSystemEvent.self, throwing: (any Swift.Error).self)

      let fileDescriptor: FileDescriptor
      do {
        fileDescriptor = try fileDescriptorClient.open(path, .readOnly, [.eventOnly])
      } catch {
        continuation.finish(throwing: error)
        return stream
      }

      let source = dispatchSourceFileSystemObjectClient.make(fileDescriptor: fileDescriptor.rawValue, eventMask: mask, queue: queue)
      dispatchSourceFileSystemObjectClient.setEventHandler(object: source, qos: .unspecified, flags: []) {
        continuation.yield(dispatchSourceFileSystemObjectClient.data(object: source))
      }
      dispatchSourceFileSystemObjectClient.resume(object: source)
      continuation.onTermination = { _ in
        dispatchSourceFileSystemObjectClient.cancel(object: source)
        let handle = dispatchSourceFileSystemObjectClient.handle(object: source)
        let fileDescriptor = FileDescriptor(rawValue: handle)
        try? fileDescriptorClient.close(fileDescriptor)
      }

      return stream
    },
    events: { paths, latency, queue, sinceWhen, flags in
      @Dependency(\.fsEventStreamClient) var fsEventStreamClient

      let defaultQueue = queue ?? DispatchQueue(label: "com.roeybiran.FSEventKit.queue", qos: .background)
      let defaultSinceWhen = sinceWhen ?? .now
      let defaultFlags = flags ?? .none

      let (stream, continuation) = AsyncThrowingStream.makeStream(of: [PathWatcherEvent].self, throwing: (any Swift.Error).self)

      var streamRef: FSEventStreamRef?

      let wrapper = EventHandlerWrapper { result in
        continuation.yield(result)
      }

      var context = FSEventStreamContext(
        version: 0,
        info: Unmanaged.passRetained(wrapper).toOpaque(),
        retain: nil,
        release: nil,
        copyDescription: nil)

      guard
        let ref = fsEventStreamClient.create(
          nil,
          { _, info, count, paths, flags, ids in
            guard
              let info = info,
              let eventPaths = Unmanaged<CFArray>
                .fromOpaque(paths)
                .takeUnretainedValue() as? [String]
            else { return }

            if count != eventPaths.count { return }

            let wrapper = Unmanaged<EventHandlerWrapper>
              .fromOpaque(info)
              .takeUnretainedValue()

            var events = [PathWatcherEvent]()

            for i in 0 ..< count {
              events.append(
                PathWatcherEvent(
                  path: eventPaths[i],
                  flag: PathWatcherEvent.Flag(rawValue: flags[i]),
                  id: PathWatcherEvent.ID(rawValue: ids[i])))
            }

            wrapper.eventHandler(events)
          },
          &context,
          paths as CFArray,
          defaultSinceWhen.rawValue,
          latency as CFTimeInterval,
          defaultFlags.union(.useCFTypes).rawValue)
      else {
        continuation.finish(throwing: PathWatcherError.streamCreationFailed)
        return stream
      }

      fsEventStreamClient.setDispatchQueue(ref, defaultQueue)

      guard fsEventStreamClient.start(ref) else {
        continuation.finish(throwing: PathWatcherError.streamStartFailed)
        return stream
      }

      continuation.onTermination = { _ in
        fsEventStreamClient.stop(ref)
      }

      return stream
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var pathWatcherClient: PathWatcherClient {
    get { self[PathWatcherClient.self] }
    set { self[PathWatcherClient.self] = newValue }
  }
}

final class EventHandlerWrapper {
  let eventHandler: (_ events: [PathWatcherEvent]) -> Void

  init(eventHandler: @escaping ([PathWatcherEvent]) -> Void) {
    self.eventHandler = eventHandler
  }
}

