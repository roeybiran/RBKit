import AppKit
import SwiftUI

struct AppImporterButtonRepresentable: NSViewRepresentable {

  // MARK: Internal

  final class Coordinator: NSObject {

    // MARK: Lifecycle

    init(bundleID: Binding<AppImporterItem.ID?>, onOtherSelected: @escaping () -> Void) {
      self.bundleID = bundleID
      self.onOtherSelected = onOtherSelected
    }

    // MARK: Internal

    var bundleID: Binding<AppImporterItem.ID?>
    var onOtherSelected: () -> Void

    @objc
    func selectOtherApp(_: Any?) {
      onOtherSelected()
    }

    @objc
    func popUpButtonAction(_ sender: Any?) {
      guard let sender = sender as? NSMenuItem else { return }
      bundleID.wrappedValue = sender.representedObject as? String
    }
  }

  @Binding var bundleID: AppImporterItem.ID?

  let apps: [AppImporterItem]
  let onOtherSelected: () -> Void

  func makeNSView(context: Context) -> NSPopUpButton {
    let popUpButton = NSPopUpButton()

    let menu = NSMenu()
    popUpButton.menu = menu

    let placeholderMenuItem = NSMenuItem(
      title: "No Selection",
      action: #selector(Coordinator.popUpButtonAction(_:)),
      keyEquivalent: "",
    )
    placeholderMenuItem.target = context.coordinator
    menu.addItem(placeholderMenuItem)
    menu.addItem(.separator())

    for app in apps {
      menu.addItem(menuItem(for: app, coordinator: context.coordinator))
    }

    menu.addItem(.separator())

    let selectionIsNonStandardApp = menu.indexOfItem(withRepresentedObject: bundleID) == -1
    if let bundleID, selectionIsNonStandardApp {
      let app = AppImporterItem(bundleID: bundleID)
      menu.addItem(menuItem(for: app, coordinator: context.coordinator))
      menu.addItem(.separator())
    }

    let selectOtherMenuItem = NSMenuItem(
      title: "Other…",
      action: #selector(Coordinator.selectOtherApp(_:)),
      keyEquivalent: "",
    )
    selectOtherMenuItem.target = context.coordinator
    menu.addItem(selectOtherMenuItem)
    return popUpButton
  }

  func updateNSView(_ popUpButton: NSPopUpButton, context _: Context) {
    let index = popUpButton.menu?.indexOfItem(withRepresentedObject: bundleID) ?? -1
    if index > -1 {
      popUpButton.selectItem(at: index)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(bundleID: $bundleID, onOtherSelected: onOtherSelected)
  }

  // MARK: Private

  private func menuItem(for app: AppImporterItem, coordinator: Coordinator) -> NSMenuItem {
    let menuItem = NSMenuItem(
      title: app.title,
      action: #selector(Coordinator.popUpButtonAction(_:)),
      keyEquivalent: "",
    )
    menuItem.target = coordinator
    menuItem.image = app.image
    menuItem.image?.size = NSSize(width: 16, height: 16)
    menuItem.representedObject = app.id
    return menuItem
  }
}
