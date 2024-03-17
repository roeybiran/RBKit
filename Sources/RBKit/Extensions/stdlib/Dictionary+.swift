extension Dictionary {
  public subscript(key: Key?) -> Value? {
    key.map { self[$0] } ?? nil
  }
}

extension Dictionary where Value: RangeReplaceableCollection {
  public subscript(key: Key?) -> Value {
    key.map { self[$0] ?? Value() } ?? Value()
  }
}
