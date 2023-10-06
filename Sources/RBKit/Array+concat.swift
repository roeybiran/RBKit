extension Array {
  public func concat(_ other: Array) -> Array {
    self + other
  }

	public func concat(_ other: Element...) -> Array {
		self + other
	}
}
