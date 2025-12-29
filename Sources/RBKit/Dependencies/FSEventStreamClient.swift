import Dependencies
import DependenciesMacros
import Foundation

// MARK: - FSEventStreamClient

@DependencyClient
public struct FSEventStreamClient: Sendable {
  public var create: @Sendable (
    _ allocator: CFAllocator?,
    _ callback: @escaping FSEventStreamCallback,
    _ context: UnsafeMutablePointer<FSEventStreamContext>,
    _ pathsToWatch: CFArray,
    _ sinceWhen: FSEventStreamEventId,
    _ latency: CFTimeInterval,
    _ flags: FSEventStreamCreateFlags
  ) -> FSEventStreamRef? = { _, _, _, _, _, _, _ in nil }

  public var setDispatchQueue: @Sendable (_ streamRef: FSEventStreamRef, _ queue: DispatchQueue?) -> Void = { _, _ in }

  public var start: @Sendable (_ streamRef: FSEventStreamRef) -> Bool = { _ in false }

  public var stop: @Sendable (_ streamRef: FSEventStreamRef) -> Void = { _ in }
}

// MARK: DependencyKey

extension FSEventStreamClient: DependencyKey {
  public static let liveValue = Self(
    create: FSEventStreamCreate,
    setDispatchQueue: FSEventStreamSetDispatchQueue,
    start: FSEventStreamStart,
    stop: FSEventStreamStop
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var fsEventStreamClient: FSEventStreamClient {
    get { self[FSEventStreamClient.self] }
    set { self[FSEventStreamClient.self] = newValue }
  }
}
