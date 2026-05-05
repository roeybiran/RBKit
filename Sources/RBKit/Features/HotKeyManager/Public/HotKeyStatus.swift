// MARK: - HotKeyStatus

public enum HotKeyStatus: Equatable, Sendable {
    case registered(HotKey)
    case failedToRegister(hotKey: HotKey, error: HotKeyManagerError)
}
