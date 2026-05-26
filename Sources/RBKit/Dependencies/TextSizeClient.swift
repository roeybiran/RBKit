import AppKit
import Dependencies
import DependenciesMacros
import Foundation

// MARK: - TextSizeClient

@DependencyClient
public struct TextSizeClient: Sendable, DependencyKey {
  public static let testValue = Self()

  public static var liveValue: TextSizeClient {
    Self(
      size: { TextSizeCache.shared.size(for: $0) }
    )
  }

  public var size: @MainActor @Sendable (_ key: TextSizeCache.Key) -> CGSize = { _ in .zero }
}

extension DependencyValues {
  public var textSizeClient: TextSizeClient {
    get { self[TextSizeClient.self] }
    set { self[TextSizeClient.self] = newValue }
  }
}

// MARK: - TextSizeCache

@MainActor
public final class TextSizeCache {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public struct Key: Hashable, Sendable {
    public init(
      fontName: String,
      fontSize: CGFloat,
      string: String,
      boldCharacterCount: Int,
    ) {
      self.fontName = fontName
      self.fontSize = fontSize
      self.string = string
      self.boldCharacterCount = boldCharacterCount
    }

    public let fontName: String
    public let fontSize: CGFloat
    public let string: String
    public let boldCharacterCount: Int
  }

  public static let shared = TextSizeCache()

  public func size(for key: Key) -> CGSize {
    if let size = sizes[key] {
      return size
    }

    guard let font = NSFont(name: key.fontName, size: key.fontSize) else {
      sizes[key] = .zero
      return .zero
    }

    let range = NSRange(location: 0, length: key.string.count)
    mutableAttributedString.mutableString.setString(key.string)
    mutableAttributedString.removeAttribute(.font, range: range)
    mutableAttributedString.addAttribute(
      .font,
      value: font,
      range: range,
    )
    if key.boldCharacterCount > 0 {
      mutableAttributedString.addAttribute(
        .font,
        value: NSFont.boldSystemFont(ofSize: key.fontSize),
        range: NSRange(location: 0, length: min(key.boldCharacterCount, mutableAttributedString.length)),
      )
    }

    let measuredSize = mutableAttributedString.size()
    let size = CGSize(
      width: ceil(measuredSize.width),
      height: ceil(measuredSize.height),
    )
    sizes[key] = size
    return size
  }

  // MARK: Private

  private let mutableAttributedString = NSMutableAttributedString()
  private var sizes = [Key: CGSize]()
}
