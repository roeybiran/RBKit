import Cocoa
import RBKit
import SwiftUI

// MARK: - OutlineViewDiffableDemoViewController

@MainActor
final class OutlineViewDiffableDemoViewController: NSViewController {

  // MARK: Internal

  override func loadView() {
    view = NSView(frame: .init(x: 0, y: 0, width: 900, height: 700))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let nameColumn = NSTableColumn(identifier: .init("nameColumn"))
    nameColumn.title = "Name"
    nameColumn.width = 320

    let pathColumn = NSTableColumn(identifier: .init("pathColumn"))
    pathColumn.title = "Path"
    pathColumn.width = 720

    outlineView.addTableColumn(nameColumn)
    outlineView.addTableColumn(pathColumn)
    outlineView.outlineTableColumn = nameColumn
    outlineView.floatsGroupRows = false
    outlineView.rowSizeStyle = .medium
    outlineView.usesAlternatingRowBackgroundColors = true
    outlineView.delegate = self

    let outlineScrollView = NSScrollView()
    outlineScrollView.translatesAutoresizingMaskIntoConstraints = false
    outlineScrollView.hasVerticalScroller = true
    outlineScrollView.documentView = outlineView

    let reloadButton = NSButton(title: "Reload", target: self, action: #selector(reloadOutline))
    let reloadWithAnimationsButton = NSButton(
      title: "Reload with Animations",
      target: self,
      action: #selector(reloadOutlineWithAnimations),
    )
    let openInFinderButton = NSButton(title: "Open in Finder", target: self, action: #selector(openInFinder))

    let controls = NSStackView(views: [reloadButton, reloadWithAnimationsButton, openInFinderButton])
    controls.orientation = .horizontal
    controls.alignment = .centerY
    controls.spacing = 8

    locationLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    locationLabel.lineBreakMode = .byTruncatingMiddle
    locationLabel.textColor = .secondaryLabelColor

    statusLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    statusLabel.lineBreakMode = .byTruncatingTail
    statusLabel.textColor = .secondaryLabelColor

    logTextView.isEditable = false
    logTextView.isSelectable = true
    logTextView.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    logTextView.string = ""

    let logScrollView = NSScrollView()
    logScrollView.translatesAutoresizingMaskIntoConstraints = false
    logScrollView.hasVerticalScroller = true
    logScrollView.documentView = logTextView

    let container = NSStackView(views: [controls, locationLabel, outlineScrollView, statusLabel, logScrollView])
    container.translatesAutoresizingMaskIntoConstraints = false
    container.orientation = .vertical
    container.spacing = 12

    view.addSubview(container)

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      container.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
      container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
      outlineScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 420),
      logScrollView.heightAnchor.constraint(equalToConstant: 160),
    ])

    dataSource.isExpandable = { !$0.children.isEmpty }
    locationLabel.stringValue = "Application Support: \(appSupportDirectoryURL.path)"
    do {
      try fileManager.createDirectory(at: appSupportDirectoryURL, withIntermediateDirectories: true)
    } catch {
      let message = "Initial Load failed | \(error.localizedDescription)"
      statusLabel.stringValue = message
      appendLog(
        """
        ACTION: Initial Load
        ERROR: \(error.localizedDescription)

        """
      )
      return
    }
    reloadFromDisk(actionName: "Initial Load", animatingDifferences: false, expandAllAfterApply: true)
  }

  // MARK: Private

  private let outlineView = NSOutlineView()
  private let locationLabel = NSTextField(labelWithString: "")
  private let statusLabel = NSTextField(labelWithString: "Reading Application Support...")
  private let logTextView = NSTextView()

  private lazy var dataSource = OutlineViewDiffableDataSource<Node>(outlineView: outlineView)

  private var currentTree: NodeTree = []
  private let fileManager = FileManager.default

  private var appSupportDirectoryURL: URL {
    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
      ?? ProcessInfo.processInfo.processName
    let baseURL = try? fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true,
    )
    return (baseURL ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support"))
      .appendingPathComponent(appName, isDirectory: true)
  }

  @objc
  private func reloadOutline() {
    reloadFromDisk(actionName: "Reload", animatingDifferences: false)
  }

  @objc
  private func reloadOutlineWithAnimations() {
    reloadFromDisk(actionName: "Reload with Animations", animatingDifferences: true)
  }

  @objc
  private func openInFinder() {
    do {
      try fileManager.createDirectory(at: appSupportDirectoryURL, withIntermediateDirectories: true)
      NSWorkspace.shared.open(appSupportDirectoryURL)
    } catch {
      let message = "Open in Finder failed | \(error.localizedDescription)"
      statusLabel.stringValue = message
      appendLog(
        """
        ACTION: Open in Finder
        ERROR: \(error.localizedDescription)

        """
      )
    }
  }

  private func reloadFromDisk(
    actionName: String,
    animatingDifferences: Bool,
    expandAllAfterApply: Bool = false,
  ) {
    let oldTree = currentTree

    do {
      let newTree = try loadRootTree()
      applyTree(
        actionName: actionName,
        oldTree: oldTree,
        newTree: newTree,
        animatingDifferences: animatingDifferences,
        expandAllAfterApply: expandAllAfterApply,
      )
    } catch {
      let message = "\(actionName) failed | \(error.localizedDescription)"
      statusLabel.stringValue = message
      appendLog(
        """
        ACTION: \(actionName)
        ERROR: \(error.localizedDescription)

        """
      )
    }
  }

  private func applyTree(
    actionName: String,
    oldTree: NodeTree,
    newTree: NodeTree,
    animatingDifferences: Bool,
    expandAllAfterApply: Bool = false,
  ) {
    let beforeExpanded = expandedIDs()
    currentTree = newTree

    var snapshot = OutlineViewDiffableSnapshot<Node>()
    snapshot.append(items: Array(newTree))

    dataSource.apply(snapshot, animatingDifferences: animatingDifferences) { [weak self] didApply in
      guard let self else { return }

      if expandAllAfterApply {
        expandAllItems()
      }

      let afterExpanded = expandedIDs()
      let status = "\(actionName) | animated: \(animatingDifferences ? "yes" : "no") | didApply: \(didApply ? "yes" : "no")"
      statusLabel.stringValue = status

      let entry = """
        ACTION: \(actionName)
        ANIMATED: \(animatingDifferences ? "YES" : "NO")
        DID_APPLY: \(didApply ? "YES" : "NO")
        BEFORE: \(oldTree.compactSummary)
        AFTER: \(newTree.compactSummary)
        EXPANDED_BEFORE: \(formattedIDs(beforeExpanded))
        EXPANDED_AFTER: \(formattedIDs(afterExpanded))

        """

      appendLog(entry)
    }
  }

  private func loadRootTree() throws -> NodeTree {
    try fileManager.createDirectory(at: appSupportDirectoryURL, withIntermediateDirectories: true)
    return try loadChildren(in: appSupportDirectoryURL)
  }

  private func loadChildren(in directoryURL: URL) throws -> NodeTree {
    let childURLs = try fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: [
        .nameKey,
        .fileResourceIdentifierKey,
        .isDirectoryKey,
        .isRegularFileKey,
        .effectiveIconKey,
      ],
      options: [.skipsHiddenFiles],
    )

    let nodes = try childURLs.map(loadNode(at:))
    let folders = nodes
      .filter(\.isFolder)
      .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    let files = nodes
      .filter(\.isFile)
      .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

    var groupedNodes = [Node]()

    if !folders.isEmpty {
      groupedNodes.append(
        .groupRow(
          parentPath: directoryURL.path,
          name: "Folders",
          children: folders,
        )
      )
    }

    if !files.isEmpty {
      groupedNodes.append(
        .groupRow(
          parentPath: directoryURL.path,
          name: "Files",
          children: files,
        )
      )
    }

    return groupedNodes
  }

  private func loadNode(at url: URL) throws -> Node {
    let values = try url.resourceValues(forKeys: [
      .nameKey,
      .fileResourceIdentifierKey,
      .isDirectoryKey,
      .effectiveIconKey,
    ])

    guard let identifierData = values.fileResourceIdentifier as? Data else {
      throw CocoaError(.fileReadUnknown)
    }

    let name = values.name ?? url.lastPathComponent
    let path = url.path
    let icon = values.effectiveIcon as? NSImage

    if values.isDirectory == true {
      let children = try loadChildren(in: url)
      return .folder(
        id: .item(identifierData),
        name: name,
        path: path,
        icon: icon,
        children: children,
      )
    }

    return .file(
      id: .item(identifierData),
      name: name,
      path: path,
      icon: icon,
    )
  }

  private func expandAllItems() {
    for node in currentTree {
      guard let row = dataSource.row(for: node), row >= 0 else { continue }
      outlineView.expandItem(outlineView.item(atRow: row), expandChildren: true)
    }
  }

  private func appendLog(_ entry: String) {
    logTextView.textStorage?.append(NSAttributedString(string: entry))
    logTextView.scrollToEndOfDocument(nil)
  }

  private func expandedIDs() -> [String] {
    var ids = [String]()

    for row in 0 ..< outlineView.numberOfRows {
      let item = outlineView.item(atRow: row)
      if !outlineView.isItemExpanded(item) { continue }
      guard let node = dataSource.itemIdentifier(forRow: row) else { continue }
      ids.append(node.id.debugName)
    }

    return ids.sorted()
  }

  private func formattedIDs(_ ids: [String]) -> String {
    if ids.isEmpty {
      return "[]"
    }

    return "[\(ids.joined(separator: ", "))]"
  }
}

// MARK: NSOutlineViewDelegate

extension OutlineViewDiffableDemoViewController: NSOutlineViewDelegate {

  // MARK: Internal

  func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    let row = outlineView.row(forItem: item)
    return dataSource.itemIdentifier(forRow: row)?.isGroupRow ?? false
  }

  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    let row = outlineView.row(forItem: item)
    return !(dataSource.itemIdentifier(forRow: row)?.isGroupRow ?? false)
  }

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    let row = outlineView.row(forItem: item)
    guard let node = dataSource.itemIdentifier(forRow: row) else { return nil }

    switch tableColumn?.identifier.rawValue {
    case "pathColumn":
      return pathCellView(for: node, outlineView: outlineView)
    default:
      return nameCellView(for: node, outlineView: outlineView)
    }
  }

  // MARK: Private

  private func nameCellView(for node: Node, outlineView: NSOutlineView) -> NSView? {
    let identifier = NSUserInterfaceItemIdentifier("NameCell")
    let cellView: NSTableCellView

    if let existing = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
      cellView = existing
    } else {
      cellView = NSTableCellView()
      cellView.identifier = identifier

      let imageView = NSImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.imageScaling = .scaleProportionallyDown
      cellView.imageView = imageView
      cellView.addSubview(imageView)

      let textField = NSTextField(labelWithString: "")
      textField.translatesAutoresizingMaskIntoConstraints = false
      textField.lineBreakMode = .byTruncatingTail
      cellView.textField = textField
      cellView.addSubview(textField)

      NSLayoutConstraint.activate([
        imageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 4),
        imageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
        imageView.widthAnchor.constraint(equalToConstant: 16),
        imageView.heightAnchor.constraint(equalToConstant: 16),
        textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
        textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -4),
        textField.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 2),
        textField.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -2),
      ])
    }

    cellView.textField?.stringValue = node.name
    cellView.imageView?.image = node.isGroupRow ? nil : node.icon

    if node.isGroupRow {
      cellView.textField?.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
      cellView.textField?.textColor = .labelColor
    } else if node.isFolder {
      cellView.textField?.font = .systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
      cellView.textField?.textColor = .labelColor
    } else {
      cellView.textField?.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
      cellView.textField?.textColor = .secondaryLabelColor
    }

    return cellView
  }

  private func pathCellView(for node: Node, outlineView: NSOutlineView) -> NSView? {
    let identifier = NSUserInterfaceItemIdentifier("PathCell")
    let cellView: NSTableCellView

    if let existing = outlineView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
      cellView = existing
    } else {
      cellView = NSTableCellView()
      cellView.identifier = identifier

      let textField = NSTextField(labelWithString: "")
      textField.translatesAutoresizingMaskIntoConstraints = false
      textField.lineBreakMode = .byTruncatingMiddle
      cellView.textField = textField
      cellView.addSubview(textField)

      NSLayoutConstraint.activate([
        textField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 4),
        textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -4),
        textField.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 2),
        textField.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -2),
      ])
    }

    cellView.textField?.stringValue = node.isGroupRow ? "" : node.path
    cellView.textField?.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    cellView.textField?.textColor = .secondaryLabelColor
    return cellView
  }
}

// MARK: - Node

nonisolated private struct Node: Identifiable, Hashable, TreeNodeProtocol {
  enum Kind: Hashable {
    case groupRow
    case folder
    case file
  }

  enum ID: Hashable {
    case item(Data)
    case group(String)

    var debugName: String {
      switch self {
      case .item(let data):
        data.map { String(format: "%02x", $0) }.joined()
      case .group(let value):
        value
      }
    }
  }

  let id: ID
  var kind: Kind
  var name: String
  var path: String
  var icon: NSImage?
  var children: NodeTree

  var isGroupRow: Bool {
    kind == .groupRow
  }

  var isFolder: Bool {
    kind == .folder
  }

  var isFile: Bool {
    kind == .file
  }

  var compactSummary: String {
    if children.isEmpty {
      return name
    }

    return "\(name){\(children.compactSummary)}"
  }

  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.name == rhs.name
      && lhs.path == rhs.path
      && lhs.children == rhs.children
  }

  static func groupRow(parentPath: String, name: String, children: [Self]) -> Self {
    .init(
      id: .group("\(parentPath)#\(name.lowercased())"),
      kind: .groupRow,
      name: name,
      path: parentPath,
      icon: nil,
      children: children,
    )
  }

  static func folder(id: ID, name: String, path: String, icon: NSImage?, children: NodeTree) -> Self {
    .init(
      id: id,
      kind: .folder,
      name: name,
      path: path,
      icon: icon,
      children: children,
    )
  }

  static func file(id: ID, name: String, path: String, icon: NSImage?) -> Self {
    .init(
      id: id,
      kind: .file,
      name: name,
      path: path,
      icon: icon,
      children: [],
    )
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(path)
    hasher.combine(children)
  }

}

private typealias NodeTree = [Node]

nonisolated extension NodeTree {
  fileprivate var compactSummary: String {
    if isEmpty {
      return "[]"
    }

    return map(\.compactSummary).joined(separator: " | ")
  }
}

// MARK: - OutlineViewDiffableDemo

struct OutlineViewDiffableDemo: NSViewControllerRepresentable {
  func makeNSViewController(context _: Context) -> OutlineViewDiffableDemoViewController {
    OutlineViewDiffableDemoViewController()
  }

  func updateNSViewController(_: OutlineViewDiffableDemoViewController, context _: Context) { }
}
