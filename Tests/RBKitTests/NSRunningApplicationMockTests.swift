import AppKit
import Testing

@testable import RBKit

@Suite
struct `NSRunningApplication.Mock Tests` {
    @Test
    func `init, should track activation policy and visibility`() async throws {
        let application = NSRunningApplication.Mock()

        #expect(application.activationPolicy == .regular)

        application._activationPolicy = .prohibited

        #expect(application.activationPolicy == .prohibited)
        #expect(application.isHidden == false)
        #expect(NSRunningApplication.Mock(_isHidden: true).isHidden == true)
    }
}
