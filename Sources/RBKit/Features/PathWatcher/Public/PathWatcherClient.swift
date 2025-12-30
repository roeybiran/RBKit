import Dependencies
import DependenciesMacros
import Foundation
import System

// MARK: - PathWatcherClient

@DependencyClient
public struct PathWatcherClient: Sendable {
  @DependencyEndpoint(method: "events")
  public var watchPath: @Sendable (
    _ path: FilePath,
    _ mask: DispatchSource.FileSystemEvent,
    _ queue: DispatchQueue?
  ) -> AsyncThrowingStream<DispatchSource.FileSystemEvent, any Swift.Error> = { _, _, _ in .finished() }

  @DependencyEndpoint(method: "events")
  public var watchPathsRecursively: @Sendable (
    _ paths: [String],
    _ latency: TimeInterval,
    _ queue: DispatchQueue?,
    _ sinceWhen: PathWatcherEvent.ID?,
    _ flags: PathWatcherFlag?
  ) -> AsyncThrowingStream<[PathWatcherEvent], any Swift.Error> = { _, _, _, _, _ in .finished() }
}

// MARK: - PathWatcherClient + DependencyKey

extension PathWatcherClient: DependencyKey {
  public static let liveValue = Self(
    watchPath: { path, mask, queue in
      @Dependency(\.fileDescriptorClient) var fileDescriptorClient
      @Dependency(\.dispatchSourceFileSystemObjectClient) var dispatchSourceFileSystemObjectClient

      let (stream, continuation) = AsyncThrowingStream.makeStream(
        of: DispatchSource.FileSystemEvent.self,
        throwing: (any Swift.Error).self
      )

      let fileDescriptor: FileDescriptor
      do {
        fileDescriptor = try fileDescriptorClient.open(path, .readOnly, [.eventOnly])
      } catch {
        continuation.finish(throwing: error)
        return stream
      }

      let source = dispatchSourceFileSystemObjectClient.make(
        fileDescriptor: fileDescriptor.rawValue,
        eventMask: mask,
        queue: queue
      )
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
    watchPathsRecursively: { paths, latency, queue, sinceWhen, flags in
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
        copyDescription: nil
      )

      guard
        let ref = fsEventStreamClient.create(
          allocator: nil,
          callback: { _, info, count, paths, flags, ids in
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
                  id: ids[i]
                )
              )
            }

            wrapper.eventHandler(events)
          },
          context: &context,
          pathsToWatch: paths as CFArray,
          sinceWhen: defaultSinceWhen,
          latency: latency as CFTimeInterval,
          flags: defaultFlags.union(.useCFTypes).rawValue
        )
      else {
        continuation.finish(throwing: PathWatcherError.streamCreationFailed)
        return stream
      }

      fsEventStreamClient.setDispatchQueue(streamRef: ref, queue: defaultQueue)

      guard fsEventStreamClient.start(streamRef: ref) else {
        continuation.finish(throwing: PathWatcherError.streamStartFailed)
        return stream
      }

      continuation.onTermination = { _ in
        fsEventStreamClient.stop(streamRef: ref)
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

  // MARK: Lifecycle

  init(eventHandler: @escaping ([PathWatcherEvent]) -> Void) {
    self.eventHandler = eventHandler
  }

  // MARK: Internal

  let eventHandler: (_ events: [PathWatcherEvent]) -> Void

}
