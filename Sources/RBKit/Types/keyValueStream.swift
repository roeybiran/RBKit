import Foundation

public typealias KeyValueStream<A, T> = (object: A, change: KeyValueObservedChange<T>)

public func keyValueStream<A: NSObject, T: Sendable>(
  observed: A,
  keyPath: KeyPath<A, T>,
  options: NSKeyValueObservingOptions = [.initial, .new])
-> AsyncStream<KeyValueStream<A, T>>
{
  let (stream, cont) = AsyncStream.makeStream(of: KeyValueStream<A, T>.self)
  let observation = observed.observe(keyPath, options: options) { object, change in
    cont.yield((object: object, change: KeyValueObservedChange(change)))
  }
  cont.onTermination = { _ in
    observation.invalidate()
  }
  return stream
}
