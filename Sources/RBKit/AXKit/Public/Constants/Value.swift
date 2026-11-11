// MARK: - Value

public enum Value: Sendable { }

// MARK: - SortDirection

public enum SortDirection: String, Sendable {
  case ascending = "AXAscendingSortDirection"
  case descending = "AXDescendingSortDirection"
  case unknown = "AXUnknownSortDirection"
}

// MARK: - Orientation

public enum Orientation: String, Sendable {
  case horizontal = "AXHorizontalOrientation"
  case vertical = "AXVerticalOrientation"
  case unknown = "AXUnknownOrientation"
}
