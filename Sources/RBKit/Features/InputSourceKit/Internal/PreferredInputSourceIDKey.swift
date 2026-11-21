import Sharing

private let inputSourcePrefix = "RBInputSourceKit_"
private let preferredInputSourceIDKey = "\(inputSourcePrefix)preferredInputSourceID"

extension SharedReaderKey where Self == AppStorageKey<InputSource.ID?>.Default {
  static var preferredInputSourceID: Self {
    Self[.appStorage(preferredInputSourceIDKey), default: nil]
  }
}
