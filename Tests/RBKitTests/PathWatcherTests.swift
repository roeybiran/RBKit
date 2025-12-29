import Dependencies
import Foundation
import System
import Testing
import RBKitTestSupport

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
            $0.fileDescriptorClient.open = { _, _, _ in
                FileDescriptor(rawValue: open(NSTemporaryDirectory(), O_EVTONLY))
            }
            $0.fileDescriptorClient.close = { _ in }
            let fileDescriptorClient = $0.fileDescriptorClient
            let dispatchSourceFileSystemObjectClient = $0.dispatchSourceFileSystemObjectClient
            $0.pathWatcherClient = PathWatcherClient(
                pathMonitor: { path, mask, queue in
                    let (stream, continuation) = AsyncThrowingStream.makeStream(of: DispatchSource.FileSystemEvent.self, throwing: Error.self)

                    let fileDescriptor: FileDescriptor
                    do {
                        fileDescriptor = try fileDescriptorClient.open(path, .readOnly, [.eventOnly])
                    } catch {
                        continuation.finish(throwing: error)
                        return stream
                    }

                    let source = dispatchSourceFileSystemObjectClient.make(fileDescriptor: fileDescriptor.rawValue, eventMask: mask, queue: queue)
                    dispatchSourceFileSystemObjectClient.setEventHandler(object: source, qos: .unspecified, flags: []) {
                        continuation.yield(dispatchSourceFileSystemObjectClient.data(object: source))
                    }
                    dispatchSourceFileSystemObjectClient.resume(object: source)
                    continuation.onTermination = { _ in
                        dispatchSourceFileSystemObjectClient.cancel(object: source)
                        let handle = dispatchSourceFileSystemObjectClient.handle(object: source)
                        let fileDescriptor = FileDescriptor(rawValue: handle)
                        try? fileDescriptorClient.close(fileDescriptor)
                    }

                    return stream
                }
            )
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                do {
                    let tempPath = FilePath(NSTemporaryDirectory())
                    for try await event in client.pathMonitor(tempPath, .write, nil) {
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
        try await withDependencies {
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let nonExistingPath = FilePath("/non/existing/path")
            var didThrow = false

            do {
                for try await _ in client.pathMonitor(nonExistingPath, .write, nil) {
                    Issue.record("Should have thrown for non-existing path")
                    break
                }
            } catch {
                didThrow = true
            }

            #expect(didThrow)
        }
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
            $0.fileDescriptorClient.open = { _, _, _ in
                FileDescriptor(rawValue: open(NSTemporaryDirectory(), O_EVTONLY))
            }
            $0.fileDescriptorClient.close = { _ in }
            let fileDescriptorClient = $0.fileDescriptorClient
            let dispatchSourceFileSystemObjectClient = $0.dispatchSourceFileSystemObjectClient
            $0.pathWatcherClient = PathWatcherClient(
                pathMonitor: { path, mask, queue in
                    let (stream, continuation) = AsyncThrowingStream.makeStream(of: DispatchSource.FileSystemEvent.self, throwing: Error.self)

                    let fileDescriptor: FileDescriptor
                    do {
                        fileDescriptor = try fileDescriptorClient.open(path, .readOnly, [.eventOnly])
                    } catch {
                        continuation.finish(throwing: error)
                        return stream
                    }

                    let source = dispatchSourceFileSystemObjectClient.make(fileDescriptor: fileDescriptor.rawValue, eventMask: mask, queue: queue)
                    dispatchSourceFileSystemObjectClient.setEventHandler(object: source, qos: .unspecified, flags: []) {
                        continuation.yield(dispatchSourceFileSystemObjectClient.data(object: source))
                    }
                    dispatchSourceFileSystemObjectClient.resume(object: source)
                    continuation.onTermination = { _ in
                        dispatchSourceFileSystemObjectClient.cancel(object: source)
                        let handle = dispatchSourceFileSystemObjectClient.handle(object: source)
                        let fileDescriptor = FileDescriptor(rawValue: handle)
                        try? fileDescriptorClient.close(fileDescriptor)
                    }

                    return stream
                }
            )
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                let tempPath = FilePath(NSTemporaryDirectory())
                for try await _ in client.pathMonitor(tempPath, .write, nil) { }
            }

            try await Task.sleep(for: .milliseconds(10))

            task.cancel()

            try await Task.sleep(for: .milliseconds(50))

            #expect(cancelCalled)
            #expect(handleCalled)
        }
    }
}
