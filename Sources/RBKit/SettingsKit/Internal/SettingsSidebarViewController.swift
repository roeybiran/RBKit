import AppKit

/// A source list of the settings panes.
final class SettingsSidebarViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Lifecycle

  init(panes: [Pane], onSelect: @escaping (Int) -> Void) {
    self.panes = panes
    self.onSelect = onSelect
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  let tableView = NSTableView()

  override func loadView() {
    let column = NSTableColumn(identifier: .init("pane"))
    tableView.addTableColumn(column)
    tableView.headerView = nil
    tableView.style = .sourceList
    tableView.rowSizeStyle = .default
    tableView.allowsEmptySelection = false
    tableView.allowsMultipleSelection = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.setAccessibilityLabel("Settings")

    let scrollView = NSScrollView()
    scrollView.documentView = tableView
    scrollView.hasVerticalScroller = true
    scrollView.autohidesScrollers = true
    scrollView.drawsBackground = false
    view = scrollView
  }

  func select(_ index: Int) {
    guard tableView.selectedRow != index else { return }
    isSelectingProgrammatically = true
    tableView.selectRowIndexes([index], byExtendingSelection: false)
    tableView.scrollRowToVisible(index)
    isSelectingProgrammatically = false
  }

  func numberOfRows(in _: NSTableView) -> Int {
    panes.count
  }

  func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
    let cell = tableView.makeView(withIdentifier: Self.cellIdentifier, owner: self) as? NSTableCellView
      ?? makeCell()
    let pane = panes[row]
    cell.textField?.stringValue = pane.label
    cell.imageView?.image = NSImage(systemSymbolName: pane.systemImage, accessibilityDescription: nil)
    return cell
  }

  func tableViewSelectionDidChange(_: Notification) {
    guard !isSelectingProgrammatically, tableView.selectedRow >= 0 else { return }
    onSelect(tableView.selectedRow)
  }

  // MARK: Private

  private static let cellIdentifier = NSUserInterfaceItemIdentifier("SettingsSidebarCell")

  private let panes: [Pane]
  private let onSelect: (Int) -> Void
  private var isSelectingProgrammatically = false

  private func makeCell() -> NSTableCellView {
    let cell = NSTableCellView()
    cell.identifier = Self.cellIdentifier

    let imageView = NSImageView()
    imageView.symbolConfiguration = .init(scale: .medium)
    imageView.contentTintColor = .controlAccentColor
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let textField = NSTextField(labelWithString: "")
    textField.lineBreakMode = .byTruncatingTail
    textField.translatesAutoresizingMaskIntoConstraints = false

    cell.addSubview(imageView)
    cell.addSubview(textField)
    cell.imageView = imageView
    cell.textField = textField

    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
      imageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 20),
      textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 6),
      textField.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -2),
      textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
    ])
    return cell
  }
}
