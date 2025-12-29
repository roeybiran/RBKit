import Dependencies
import DependenciesMacros
import Foundation
import System

// MARK: - FileDescriptorClient

@DependencyClient
public struct FileDescriptorClient: Sendable {
  public var open: @Sendable (
    _ path: FilePath,
    _ mode: FileDescriptor.AccessMode,
    _ options: FileDescriptor.OpenOptions
  ) throws -> FileDescriptor
  public var close: @Sendable (_ fileDescriptor: FileDescriptor) throws -> Void
}

// MARK: DependencyKey

extension FileDescriptorClient: DependencyKey {
  public static let liveValue = Self(
    open: { path, mode, options in
      try FileDescriptor.open(path, mode, options: options)
    },
    close: { fileDescriptor in
      try fileDescriptor.close()
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var fileDescriptorClient: FileDescriptorClient {
    get { self[FileDescriptorClient.self] }
    set { self[FileDescriptorClient.self] = newValue }
  }
}
