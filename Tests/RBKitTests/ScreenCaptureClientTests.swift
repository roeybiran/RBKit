@preconcurrency import ScreenCaptureKit
import Testing
@testable import RBKit

struct `ScreenCaptureClient Tests` {
  @Test(.disabled("Flaky in headless environments"))
  func `liveValue, should route to ScreenCaptureKit`() async {
    let client = ScreenCaptureClient.liveValue
    _ = try? await client.excludingDesktopWindows(false, false)
    let image = try? await client.captureImage(contentFilter: .init(), configuration: .init())
    #expect(image == nil)
  }
}
