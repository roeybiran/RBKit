import Testing

@testable import RBKit

@Test @MainActor
func dockVisualEffectView() {
  let sut = DockVisualEffectView()
  #expect(sut.blendingMode == .behindWindow)
  #expect(sut.material == .fullScreenUI)
}
