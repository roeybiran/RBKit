extension Array {
  public func concat(_ other: Array) -> Array {
    self + other
  }

  public func concat(_ other: Element...) -> Array {
    self + other
  }
  
  /// If the array is empty, returns the array’s `endIndex`.
  public var lastValidIndex: Int {
    isEmpty ? endIndex : (endIndex - 1)
  }
}
