import Dependencies
import DependenciesMacros
import Foundation

// MARK: - DispatchSourceFileSystemObjectClient

// https://github.com/pointfreeco/swift-composable-architecture/blob/8a40e932cf4f5827ced0fdfc1143aebf578dcbe3/Sources/ComposableArchitecture/SharedState/PersistenceKey/FileStorageKey.swift#L223
// https://github.com/pointfreeco/swift-composable-architecture/blob/8a40e932cf4f5827ced0fdfc1143aebf578dcbe3/Tests/ComposableArchitectureTests/FileStorageTests.swift
// https://twitter.com/pointfreeco/status/1781021746365370544
// https://swiftrocks.com/dispatchsource-detecting-changes-in-files-and-folders-in-swift
// https://agostini.tech/2017/08/06/monitoring-files-using-dispatch-sources/
// https://github.com/pointfreeco/episode-code-samples/blob/2d7472cc6f33f4c290ca42e26485f04d9fc3bdd2/0275-shared-state-pt8/swift-composable-architecture/Sources/ComposableArchitecture/PersistenceKey.swift#L137

@DependencyClient
public struct DispatchSourceFileSystemObjectClient: Sendable {
  public var make: @Sendable (_ fileDescriptor: Int32, _ eventMask: DispatchSource.FileSystemEvent, _ queue: DispatchQueue?)
    -> any DispatchSourceFileSystemObject = { _, _, _ in DispatchSourceFileSystemObjectMock() }
  public var setEventHandler: @Sendable (
    _ object: any DispatchSourceFileSystemObject,
    _ qos: DispatchQoS,
    _ flags: DispatchWorkItemFlags,
    _ handler: DispatchSource.DispatchSourceHandler?
  ) -> Void = { _, _, _, _ in }
  public var resume: @Sendable (_ object: any DispatchSourceFileSystemObject) -> Void = { _ in }
  public var cancel: @Sendable (_ object: any DispatchSourceFileSystemObject) -> Void = { _ in }
  public var data: @Sendable (_ object: any DispatchSourceFileSystemObject) -> DispatchSource.FileSystemEvent = { _ in .write }
  public var handle: @Sendable (_ object: any DispatchSourceFileSystemObject) -> Int32 = { _ in 0 }

  public func pathMonitor(
    path: String,
    mask: DispatchSource.FileSystemEvent,
    queue: DispatchQueue?
  ) -> AsyncStream<DispatchSource.FileSystemEvent> {
    let (stream, continuation) = AsyncStream.makeStream(of: DispatchSource.FileSystemEvent.self)
    let source = make(fileDescriptor: open(path, O_EVTONLY), eventMask: mask, queue: queue)
    setEventHandler(object: source, qos: .unspecified, flags: []) {
      continuation.yield(data(object: source))
    }
    resume(object: source)
    continuation.onTermination = { _ in
      cancel(object: source)
      let handle = handle(object: source)
      close(handle)
    }
    return stream
  }
}

// MARK: DependencyKey

extension DispatchSourceFileSystemObjectClient: DependencyKey {
  public static let liveValue = Self(
    make: DispatchSource.makeFileSystemObjectSource,
    setEventHandler: { $0.setEventHandler(qos: $1, flags: $2, handler: $3) },
    resume: { $0.resume() },
    cancel: { $0.cancel() },
    data: { $0.data },
    handle: { $0.handle }
  )
  public static let testValue = Self()
}

extension DependencyValues {
  public var dispatchSourceFileSystemObjectClient: DispatchSourceFileSystemObjectClient {
    get { self[DispatchSourceFileSystemObjectClient.self] }
    set { self[DispatchSourceFileSystemObjectClient.self] = newValue }
  }
}
