import Dependencies
import DependenciesMacros
@preconcurrency import ScreenCaptureKit

// MARK: - ScreenCaptureClient

@DependencyClient
public struct ScreenCaptureClient: Sendable {
  public var excludingDesktopWindows: @Sendable (_ excludingDesktopWindows: Bool, _ onScreenWindowsOnly: Bool) async throws
    -> SCShareableContent
  public var captureImage: @Sendable (_ contentFilter: SCContentFilter, _ configuration: SCStreamConfiguration) async throws
    -> CGImage
}

// MARK: DependencyKey

extension ScreenCaptureClient: DependencyKey {
  public static let liveValue = Self(
    excludingDesktopWindows: { excludingDesktopWindows, onScreenWindowsOnly in
      try await SCShareableContent.excludingDesktopWindows(excludingDesktopWindows, onScreenWindowsOnly: onScreenWindowsOnly)
    },
    captureImage: { contentFilter, configuration in
      try await SCScreenshotManager.captureImage(contentFilter: contentFilter, configuration: configuration)
    },
  )

  public static let testValue = Self()
}

extension DependencyValues {
  public var screenCaptureClient: ScreenCaptureClient {
    get { self[ScreenCaptureClient.self] }
    set { self[ScreenCaptureClient.self] = newValue }
  }
}
