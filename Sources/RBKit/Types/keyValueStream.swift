import Foundation

public func keyValueStream<A: NSObject, T: Sendable>(
  observed: A,
  keyPath: KeyPath<A, T>,
  options: NSKeyValueObservingOptions = [.initial, .new])
-> AsyncStream<KeyValueObservedChange<T>>
{
  let (stream, cont) = AsyncStream.makeStream(of: KeyValueObservedChange<T>.self)
  let observation = observed.observe(keyPath, options: options) {  _, change in
    cont.yield(KeyValueObservedChange(change))
  }
  cont.onTermination = { _ in
    observation.invalidate()
  }
  return stream
}

