import AppKit

extension NSCollectionView {
  public func register(supplementary view: NSView.Type) {
    register(view, forSupplementaryViewOfKind: view.supplementaryViewKind, withIdentifier: view.userInterfaceIdentifier)
  }

  public func register(item: NSCollectionViewItem.Type) {
    register(item, forItemWithIdentifier: item.userInterfaceIdentifier)
  }

  public func makeSupplementaryView<T: NSView & NSCollectionViewElement>(ofKind elementKind: T.Type, for indexPath: IndexPath) -> T? {
    makeSupplementaryView(
      ofKind: elementKind.supplementaryViewKind,
      withIdentifier: elementKind.userInterfaceIdentifier,
      for: indexPath) as? T
  }

  public func makeItem<T: NSCollectionViewElement & UserInterfaceItemIdentifiable>(of type: T.Type, for indexPath: IndexPath) -> T? {
    makeItem(withIdentifier: T.userInterfaceIdentifier, for: indexPath) as? T
  }
}
