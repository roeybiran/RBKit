import Carbon
import Dependencies
import DependenciesMacros

// MARK: - SecureEventInputClient

@DependencyClient
public struct SecureEventInputClient {
  // https://developer.apple.com/library/archive/technotes/tn2150/_index.html
  // https://alexwlchan.net/2021/secure-input/
  public var updates: (_ interval: TimeInterval) -> AsyncStream<Bool> = { _ in .finished }
  public var isEnabled: () -> Bool = { false }
}

// MARK: DependencyKey

extension SecureEventInputClient: DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    updates: { interval in
      .init { continuation in
        Task {
          while !Task.isCancelled {
            try? await Task.sleep(forSeconds: interval)
            continuation.yield(isEnabled())
          }
        }
      }
    },
    isEnabled: isEnabled)
  public static let testValue = Self()

  // MARK: Private

  private static var isEnabled = IsSecureEventInputEnabled
}

extension DependencyValues {
  public var secureEventInputClient: SecureEventInputClient {
    get { self[SecureEventInputClient.self] }
    set { self[SecureEventInputClient.self] = newValue }
  }
}
