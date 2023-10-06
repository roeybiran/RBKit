// https://www.hackingwithswift.com/example-code/language/how-to-make-array-access-safer-using-a-custom-subscript

extension Collection {
  public subscript(safe index: Index) -> Element? {
    startIndex <= index && index < endIndex ? self[index] : nil
  }
}
