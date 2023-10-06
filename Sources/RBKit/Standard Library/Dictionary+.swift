extension Dictionary {
  public subscript<T>(key: Key?) -> [T] where Value == [T], Key == String {
    self[key ?? "", default: []]
  }
}
