import Foundation

// MARK: - KeyValueObservation

public struct KeyValueObservation {
  public let value: NSObject
  public var invalidate: () -> Void

  public init(value: NSObject = .init(), invalidate: @escaping () -> Void = { }) {
    self.value = value
    self.invalidate = invalidate
  }
}

// MARK: Hashable

extension KeyValueObservation: Hashable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.value == rhs.value
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }

}
