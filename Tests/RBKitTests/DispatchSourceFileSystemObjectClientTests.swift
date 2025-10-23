import Dependencies
import Foundation
import System
import Testing

@testable import RBKit

@Suite
struct `DispatchSourceFileSystemObjectClient Tests` {
    @Test
    func `pathMonitor, with existing path, should forward file system events`() async throws {
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
                do {
                    let tempPath = FilePath(NSTemporaryDirectory())
                    for try await event in client.pathMonitor(path: tempPath, mask: .write, queue: nil) {
                        #expect(event == .write)
                        break
                    }
                } catch {
                    Issue.record("Failed with error: \(error)")
                }
            }
            task.cancel()
        }
    }

    @Test
    func `pathMonitor, with non-existing path, should throw`() async throws {
        @Dependency(\.dispatchSourceFileSystemObjectClient) var client

        let nonExistingPath = FilePath("/non/existing/path")
        var didThrow = false

        do {
            for try await _ in client.pathMonitor(path: nonExistingPath, mask: .write, queue: nil) {
                Issue.record("Should have thrown for non-existing path")
                break
            }
        } catch {
            didThrow = true
        }

        #expect(didThrow)
    }

    @Test
    func `pathMonitor, when cancelled, should call cancel and handle endpoints`() async throws {
        nonisolated(unsafe) var cancelCalled = false
        nonisolated(unsafe) var handleCalled = false

        try await withDependencies {
            $0.dispatchSourceFileSystemObjectClient.make = { _, _, _ in
                DispatchSourceFileSystemObjectMock()
            }
            $0.dispatchSourceFileSystemObjectClient.cancel = { _ in
                cancelCalled = true
            }
            $0.dispatchSourceFileSystemObjectClient.resume = { _ in }
            $0.dispatchSourceFileSystemObjectClient.setEventHandler = { _, _, _, _ in }
            $0.dispatchSourceFileSystemObjectClient.data = { _ in .write }
            $0.dispatchSourceFileSystemObjectClient.handle = { _ in
                handleCalled = true
                return 0
            }
        } operation: {
            @Dependency(\.dispatchSourceFileSystemObjectClient) var client

            let task = Task {
                let tempPath = FilePath(NSTemporaryDirectory())
                for try await _ in client.pathMonitor(path: tempPath, mask: .write, queue: nil) { }
            }

            try await Task.sleep(for: .milliseconds(10))

            task.cancel()

            try await Task.sleep(for: .milliseconds(50))

            #expect(cancelCalled)
            #expect(handleCalled)
        }
    }
}
