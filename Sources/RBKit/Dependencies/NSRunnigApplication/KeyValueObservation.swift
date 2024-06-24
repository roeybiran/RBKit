import Foundation

public struct KeyValueObservation {
  public let value: NSObject
  public var invalidate: () -> Void

  public init(value: NSObject = .init(), invalidate: @escaping () -> Void = { }) {
    self.value = value
    self.invalidate = invalidate
  }
}

extension KeyValueObservation: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value == rhs.value
  }
}
