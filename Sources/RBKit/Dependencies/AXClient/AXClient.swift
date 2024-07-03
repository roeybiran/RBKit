import ApplicationServices
import Dependencies
import DependenciesMacros

// MARK: - AXClient

@DependencyClient
public struct AXClient {
  public var isProcessTrusted: (_ usePrompt: Bool) -> Bool = { _ in false }
}

// MARK: DependencyKey

extension AXClient: DependencyKey {
  public static let liveValue = Self(
    isProcessTrusted: { usePrompt in
      if usePrompt {
        return AXIsProcessTrusted()
      } else {
        return AXIsProcessTrustedWithOptions(.withPrompt(usePrompt))
      }
    }
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var axClient: AXClient {
    get { self[AXClient.self] }
    set { self[AXClient.self] = newValue }
  }
}

private extension CFDictionary {
  static func withPrompt(_ flag: Bool) -> CFDictionary {
    [
      kAXTrustedCheckOptionPrompt.takeUnretainedValue(): flag
      ? kCFBooleanTrue
      : kCFBooleanFalse,
    ] as CFDictionary
  }
}
