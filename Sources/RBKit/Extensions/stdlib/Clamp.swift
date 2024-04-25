public func clamp<T>(min minValue: T, ideal: T, max maxValue: T) -> T where T: Comparable {
  max(minValue, min(ideal, maxValue))
}
