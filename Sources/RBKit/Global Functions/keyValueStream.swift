import Foundation

public func keyValueChangeStream<A: NSObject, T: Sendable>(
  observed: A,
  keyPath: KeyPath<A, T>,
  options: NSKeyValueObservingOptions = [.initial, .new],
) -> AsyncStream<KeyValueObservedChange<T>> {
  let (stream, continuation) = AsyncStream.makeStream(of: KeyValueObservedChange<T>.self)
  let observation = observed.observe(keyPath, options: options) { _, change in
    continuation.yield(
      .init(
        kind: change.kind,
        oldValue: change.oldValue,
        newValue: change.newValue,
        indexes: change.indexes,
        isPrior: change.isPrior,
      )
    )
  }
  continuation.onTermination = { _ in
    observation.invalidate()
  }
  return stream
}
