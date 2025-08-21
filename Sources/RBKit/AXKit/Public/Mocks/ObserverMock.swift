open class ObserverMock: Hashable {
  public let id: String
  
  public init(id: String = "") {
    self.id = id
  }
  
  public static func == (lhs: ObserverMock, rhs: ObserverMock) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
