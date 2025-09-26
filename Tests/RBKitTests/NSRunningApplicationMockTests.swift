import AppKit
import Testing

@testable import RBKit

@Suite
struct `NSRunningApplication Mock Tests` {
    @Test
    func `Mock tracks activation policy and visibility`() {
        let application = NSRunningApplication.Mock()

        #expect(application.activationPolicy == .regular)

        application._activationPolicy = .prohibited

        #expect(application.activationPolicy == .prohibited)
        #expect(application.isHidden == false)
        #expect(NSRunningApplication.Mock(_isHidden: true).isHidden == true)
    }
}
