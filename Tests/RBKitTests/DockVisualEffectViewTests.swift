import Testing

@testable import RBKit

@MainActor
@Suite
struct `DockVisualEffectView Tests` {
    @Test
    func `init, should use dock appearance defaults`() async throws {
        let view = DockVisualEffectView()

        #expect(view.blendingMode == .behindWindow)
        #expect(view.material == .fullScreenUI)
    }
}
