import Dependencies
import Foundation
import Testing

@testable import RBKit

@Suite
struct `DispatchSourceFileSystemObject Client Tests` {
    @Test
    func `Path monitor forwards file system events`() async throws {
        withDependencies {
            $0.dispatchSourceFileSystemObjectClient.make = { _, _, _ in
                DispatchSourceFileSystemObjectMock()
            }
            $0.dispatchSourceFileSystemObjectClient.cancel = { _ in }
            $0.dispatchSourceFileSystemObjectClient.resume = { _ in }
            $0.dispatchSourceFileSystemObjectClient.setEventHandler = { _, _, _, _ in }
            $0.dispatchSourceFileSystemObjectClient.data = { _ in .write }
            $0.dispatchSourceFileSystemObjectClient.handle = { _ in
                open(NSTemporaryDirectory(), O_EVTONLY)
            }
        } operation: {
            @Dependency(\.dispatchSourceFileSystemObjectClient) var client

            let task = Task {
                for await event in client.pathMonitor(path: NSTemporaryDirectory(), mask: .write, queue: nil) {
                    #expect(event == .write)
                    break
                }
            }
            task.cancel()
        }
    }
}
