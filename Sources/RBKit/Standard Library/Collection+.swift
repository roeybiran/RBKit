// https://www.hackingwithswift.com/example-code/language/how-to-make-array-access-safer-using-a-custom-subscript

extension Collection {
  public subscript(safe index: Index) -> Element? {
    startIndex <= index && index < endIndex ? self[index] : nil
  }

  public var isNotEmpty: Bool {
    !isEmpty
  }

  public func item(at index: Index) -> Element {
    self[index]
  }

  public func item(optionallyAt safeIndex: Index) -> Element? {
    self[safe: safeIndex]
  }
}
