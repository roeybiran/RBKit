import Cocoa

/// An `NSScrollView` with an `intrinsicContentSize`, derived from a enclosed `NSTableView`.
final class DynamicHeightScrollView: NSScrollView {

  // MARK: Lifecycle

  init(tableView: NSTableView, maxVisibleRows: Int = 24) {
    self.maxVisibleRows = maxVisibleRows
    self.tableView = tableView

    super.init(frame: .zero)

    documentView = tableView
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  func updateHeight() {
    // We use `numberOfRows` instead of `dataSource.numberOfRows(in:)` as the latter will always return 0 if the view is an NSOutlineView.
    // The discussion here https://developer.apple.com/documentation/appkit/nstableview/1527941-numberofrows# says "Typically you should not ask the table view how many rows it has; instead, interrogate the table view's data source.";
    // However, the header (NSTableView.h:222) mentions no such thing.
    let rowHeight = tableView.rowHeight
    let itemCount = tableView.numberOfRows
    let actualHeight = CGFloat(itemCount) * rowHeight
    var maximumHeight = (CGFloat(min(maxVisibleRows, itemCount)) * rowHeight) + (tableView.headerView?.frame.height ?? .zero)

    if itemCount > 0 {
      // This calculation takes into account the Big Sur inset-style table view padding.
      // We add this value twice - for the top AND bottom insets
      // NSTableView's `intrinsicContentSize` doesn't include the headerView's size/height!
      maximumHeight += ((tableView.intrinsicContentSize.height) - actualHeight) * 2
    }

    if constraint == nil {
      constraint = heightAnchor.constraint(equalToConstant: .zero)
      // IMPORTANT! without this we'll get runtime auto layout errors!
      constraint?.priority = .defaultHigh - 1
      constraint?.isActive = true
    }

    NSAnimationContext.current.duration = 0.2
    NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    constraint?.constant = maximumHeight
  }

  // MARK: Private

  private var constraint: NSLayoutConstraint?
  private let maxVisibleRows: Int
  private let tableView: NSTableView
}
