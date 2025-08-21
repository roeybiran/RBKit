open class RunLoopSourceMock: Hashable {
  public let id: String
  
  public init(id: String = "") {
    self.id = id
  }
  
  public static func == (lhs: RunLoopSourceMock, rhs: RunLoopSourceMock) -> Bool {
    return lhs.id == rhs.id
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

