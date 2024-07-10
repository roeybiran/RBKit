import Dependencies
import DependenciesMacros
import ScreenCaptureKit

// MARK: - ScreenCaptureClient

@available(macOS 12.3, *)
@DependencyClient
public struct ScreenCaptureClient {
  public var current: () async throws -> SCShareableContent
  public var requestAccess: () async -> Void
}

// MARK: DependencyKey

@available(macOS 12.3, *)
extension ScreenCaptureClient: DependencyKey {
  public static let liveValue: Self = .init(
    current: { try await SCShareableContent.current },
    requestAccess: {
      _ = try? await SCShareableContent.current
    })

  public static let testValue = Self()
}

@available(macOS 12.3, *)
extension DependencyValues {
  public var screenCaptureClient: ScreenCaptureClient {
    get { self[ScreenCaptureClient.self] }
    set { self[ScreenCaptureClient.self] = newValue }
  }
}
