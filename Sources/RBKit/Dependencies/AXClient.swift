@preconcurrency import ApplicationServices
import Dependencies
import DependenciesMacros

// MARK: - AXClient

@DependencyClient
public struct AXClient: Sendable {
  public var isProcessTrusted: @Sendable (_ usePrompt: Bool) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension AXClient: DependencyKey {
  public static let liveValue = Self(
    isProcessTrusted: { usePrompt in
      if usePrompt {
        return AXIsProcessTrustedWithOptions(.withPrompt(usePrompt))
      } else {
        return AXIsProcessTrusted()
      }
    })

  public static let testValue = Self()
}

extension DependencyValues {
  public var axClient: AXClient {
    get { self[AXClient.self] }
    set { self[AXClient.self] = newValue }
  }
}

extension CFDictionary {
  fileprivate static func withPrompt(_ flag: Bool) -> CFDictionary {
    [
      kAXTrustedCheckOptionPrompt.takeUnretainedValue(): flag
        ? kCFBooleanTrue
        : kCFBooleanFalse,
    ] as CFDictionary
  }
}
