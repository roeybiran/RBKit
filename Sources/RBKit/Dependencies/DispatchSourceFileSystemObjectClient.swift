import Dependencies
import DependenciesMacros
import Foundation

// MARK: - DispatchSourceFileSystemObjectClient

@DependencyClient
public struct DispatchSourceFileSystemObjectClient: Sendable {
  public var make:
    @Sendable (
      _ path: UnsafePointer<CChar>,
      _ mask: DispatchSource.FileSystemEvent,
      _ handler: @escaping (_ event: DispatchSource.FileSystemEvent) -> Void) -> Void
}

// MARK: DependencyKey

// https://github.com/pointfreeco/swift-composable-architecture/blob/8a40e932cf4f5827ced0fdfc1143aebf578dcbe3/Tests/ComposableArchitectureTests/FileStorageTests.swift
// https://twitter.com/pointfreeco/status/1781021746365370544
// https://swiftrocks.com/dispatchsource-detecting-changes-in-files-and-folders-in-swift
// https://agostini.tech/2017/08/06/monitoring-files-using-dispatch-sources/
// https://github.com/pointfreeco/episode-code-samples/blob/2d7472cc6f33f4c290ca42e26485f04d9fc3bdd2/0275-shared-state-pt8/swift-composable-architecture/Sources/ComposableArchitecture/PersistenceKey.swift#L137

extension DispatchSourceFileSystemObjectClient: DependencyKey {
  public static let liveValue = Self(
    make: { path, mask, handler in
      let source =
        DispatchSource
          .makeFileSystemObjectSource(
            fileDescriptor: open(path, O_EVTONLY),
            eventMask: mask,
            queue: nil)
      source.setEventHandler {
        handler(source.data)
      }
      source.resume()
    })

  public static let testValue = Self()
}

extension DependencyValues {
  public var dispatchSourceFileSystemObjectClient: DispatchSourceFileSystemObjectClient {
    get { self[DispatchSourceFileSystemObjectClient.self] }
    set { self[DispatchSourceFileSystemObjectClient.self] = newValue }
  }
}
