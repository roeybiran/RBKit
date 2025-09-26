import Testing

@testable import RBKit

@MainActor
@Suite
struct `DockVisualEffectView Tests` {
    @Test
    func `Defaults use dock appearance`() {
        let view = DockVisualEffectView()

        #expect(view.blendingMode == .behindWindow)
        #expect(view.material == .fullScreenUI)
    }
}
