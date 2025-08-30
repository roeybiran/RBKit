import Foundation

public func keyValueStream<A: NSObject, T: Sendable>(
  observed: A,
  keyPath: KeyPath<A, T>,
  options: NSKeyValueObservingOptions = [.initial, .new]
) -> AsyncStream<(object: A, change: NSKeyValueObservedChange<T>)> {
  let (stream, cont) = AsyncStream.makeStream(of: (object: A, change: NSKeyValueObservedChange<T>).self)
  let observation = observed.observe(keyPath, options: options) { object, change in
    cont.yield((object: object, change: change))
  }
  cont.onTermination = { _ in
    observation.invalidate()
  }
  return stream
}
