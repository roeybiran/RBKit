extension String {
  public func normalized() -> Self {
    lowercased().replacingOccurrences(of: " ", with: "")
  }
}
