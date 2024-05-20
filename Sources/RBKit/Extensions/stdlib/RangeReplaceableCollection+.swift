extension RangeReplaceableCollection {
  public mutating func append(_ newElements: Element...) {
    for element in newElements {
      append(element)
    }
  }
}
