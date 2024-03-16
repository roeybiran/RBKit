extension Dictionary {
  subscript(key: Key?) -> Value? {
    key.map { self[$0] } ?? nil
  }
}

extension Dictionary where Value: RangeReplaceableCollection {
  subscript(key: Key?) -> Value {
    key.map { self[$0] ?? Value() } ?? Value()
  }
}
