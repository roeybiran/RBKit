// MARK: - Value

public enum Value { }

// MARK: - SortDirection

public enum SortDirection: String {
  case ascending = "AXAscendingSortDirection"
  case descending = "AXDescendingSortDirection"
  case unknown = "AXUnknownSortDirection"
}

// MARK: - Orientation

public enum Orientation: String {
  case horizontal = "AXHorizontalOrientation"
  case vertical = "AXVerticalOrientation"
  case unknown = "AXUnknownOrientation"
}
