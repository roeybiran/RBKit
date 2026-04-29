open class ObserverMock: Hashable {

  // MARK: Lifecycle

  public init(id: String = "") {
    self.id = id
  }

  // MARK: Public

  public let id: String

  public static func ==(lhs: ObserverMock, rhs: ObserverMock) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
