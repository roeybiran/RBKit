public func clamp<T: Comparable>(min minValue: T, ideal: T, max maxValue: T) -> T {
  max(minValue, min(ideal, maxValue))
}
