public struct EventType: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case keyDown
        case keyUp
    }

    public static let keyDown = Self(kind: .keyDown, isRepeat: false)
    public static let keyUp = Self(kind: .keyUp, isRepeat: false)

    public let kind: Kind
    public let isRepeat: Bool
}
