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
  ) -> AsyncThrowingStream<DispatchSource.FileSystemEvent, any Error> = { _, _, _ in .finished() }
  
  public var events: @Sendable (_ paths: [String], _ latency: TimeInterval) -> FSEventAsyncStream = { _, _ in .finished() }
}

// MARK: DependencyKey

extension PathWatcherClient: DependencyKey {
  public static let liveValue = Self(
    pathMonitor: { path, mask, queue in
      let fileDescriptorClient = FileDescriptorClient.liveValue
      let dispatchSourceFileSystemObjectClient = DispatchSourceFileSystemObjectClient.liveValue
      
      let (stream, continuation) = AsyncThrowingStream.makeStream(of: DispatchSource.FileSystemEvent.self, throwing: Error.self)

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
    events: { paths, latency in
      FSEventStream.events(paths: paths, latency: latency)
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

