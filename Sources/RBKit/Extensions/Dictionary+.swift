extension Dictionary {
  public subscript(key: Key?) -> Value? {
    key.map { self[$0] } ?? nil
  }

  public subscript(key: Key?, default defaultValue: @autoclosure () -> Value) -> Value {
    key.map { self[$0, default: defaultValue()] } ?? defaultValue()
  }
}
