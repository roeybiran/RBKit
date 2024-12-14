import Carbon
import Dependencies
import DependenciesMacros

@DependencyClient
public struct CGEventClient: Sendable {
  public var flags: @Sendable (_ event: CGEvent) -> CGEventFlags = { _ in [] }
  public var getIntegerValue: @Sendable (_ event: CGEvent, _ field: CGEventField) -> Int64 = { _, _ in 0 }
}

extension CGEventClient: DependencyKey {
  public static let liveValue = Self(
    flags: { $0.flags },
    getIntegerValue: { $0.getIntegerValueField($1) }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var cgEventClient: CGEventClient {
    get { self[CGEventClient.self] }
    set { self[CGEventClient.self] = newValue }
  }
}
