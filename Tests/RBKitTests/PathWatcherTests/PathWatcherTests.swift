import Dependencies
import Foundation
import RBKitTestSupport
import System
import Testing

@testable import RBKit

@Suite
struct `PathWatcher Tests` {
    @Test
    func `PathWatcherEvent init, should set all properties correctly`() {
        let path = "/tmp/test"
        let flag = PathWatcherEvent.Flag.itemCreated
        let id: PathWatcherEvent.ID = 123

        let event = PathWatcherEvent(path: path, flag: flag, id: id)

        #expect(event.path == path)
        #expect(event.flag == flag)
        #expect(event.id == id)
    }

    @Test
    func `pathMonitor, with existing path, should forward file system events`() async throws {
        nonisolated(unsafe) var openCalled = false
        nonisolated(unsafe) var closeCalled = false
        nonisolated(unsafe) var eventHandlerCalled = false
        nonisolated(unsafe) var receivedEvent: DispatchSource.FileSystemEvent?
        nonisolated(unsafe) var capturedMode: FileDescriptor.AccessMode?
        nonisolated(unsafe) var capturedOptions: FileDescriptor.OpenOptions?
        nonisolated(unsafe) var capturedFileDescriptor: FileDescriptor?
        let mockFileDescriptor = FileDescriptor(rawValue: 42)

        try await withDependencies {
            $0.fileDescriptorClient.open = { path, mode, options in
                openCalled = true
                capturedMode = mode
                capturedOptions = options
                return mockFileDescriptor
            }
            $0.fileDescriptorClient.close = { fd in
                closeCalled = true
                capturedFileDescriptor = fd
            }
            $0.dispatchSourceFileSystemObjectClient.make = { fd, mask, queue in
                return DispatchSourceFileSystemObjectMock()
            }
            $0.dispatchSourceFileSystemObjectClient.cancel = { _ in }
            $0.dispatchSourceFileSystemObjectClient.resume = { _ in }
            $0.dispatchSourceFileSystemObjectClient.setEventHandler = { _, _, _, handler in
                eventHandlerCalled = true
                // Simulate an event
                handler?()
            }
            $0.dispatchSourceFileSystemObjectClient.data = { _ in .write }
            $0.dispatchSourceFileSystemObjectClient.handle = { _ in
                mockFileDescriptor.rawValue
            }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                do {
                    let tempPath = FilePath(NSTemporaryDirectory())
                    for try await event in client.watchPath(tempPath, .write, nil) {
                        receivedEvent = event
                        break
                    }
                } catch {
                    Issue.record("Failed with error: \(error)")
                }
            }
            try await Task.sleep(for: .milliseconds(10))
            task.cancel()
            try await Task.sleep(for: .milliseconds(50))

            #expect(openCalled)
            #expect(capturedMode == .readOnly)
            #expect(capturedOptions?.contains(.eventOnly) == true)
            #expect(eventHandlerCalled)
            #expect(receivedEvent == .write)
            #expect(closeCalled)
            #expect(capturedFileDescriptor?.rawValue == mockFileDescriptor.rawValue)
        }
    }

    @Test
    func `pathMonitor, with non-existing path, should throw`() async throws {
        nonisolated(unsafe) var openCalled = false

        struct TestError: Error {}

        await withDependencies {
            $0.fileDescriptorClient.open = { _, _, _ in
                openCalled = true
                throw TestError()
            }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let nonExistingPath = FilePath("/non/existing/path")

            await #expect(throws: TestError.self) {
                for try await _ in client.watchPath(nonExistingPath, .write, nil) {}
            }

            try? await Task.sleep(for: .milliseconds(10))

            #expect(openCalled)
        }
    }

    @Test
    func `pathMonitor, when cancelled, should call cancel and handle endpoints`() async throws {
        nonisolated(unsafe) var cancelCalled = false
        nonisolated(unsafe) var handleCalled = false
        nonisolated(unsafe) var closeCalled = false
        let mockFileDescriptor = FileDescriptor(rawValue: 42)

        try await withDependencies {
            $0.fileDescriptorClient.open = { _, _, _ in
                mockFileDescriptor
            }
            $0.fileDescriptorClient.close = { _ in
                closeCalled = true
            }
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
                return mockFileDescriptor.rawValue
            }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                let tempPath = FilePath(NSTemporaryDirectory())
                for try await _ in client.watchPath(tempPath, .write, nil) {}
            }

            try await Task.sleep(for: .milliseconds(10))
            task.cancel()
            try await Task.sleep(for: .milliseconds(50))

            #expect(cancelCalled)
            #expect(handleCalled)
            #expect(closeCalled)
        }
    }

    @Test
    func `events, with successful stream creation, should yield events`() async throws {
        nonisolated(unsafe) var capturedCallback: FSEventStreamCallback?
        nonisolated(unsafe) var capturedContext: FSEventStreamContext?
        nonisolated(unsafe) var capturedPaths: CFArray?
        nonisolated(unsafe) var capturedSinceWhen: FSEventStreamEventId?
        nonisolated(unsafe) var capturedLatency: CFTimeInterval?
        nonisolated(unsafe) var capturedFlags: FSEventStreamCreateFlags?
        nonisolated(unsafe) var setDispatchQueueCalled = false
        nonisolated(unsafe) var setDispatchQueueQueue: DispatchQueue?
        nonisolated(unsafe) var startCalled = false
        nonisolated(unsafe) var stopCalled = false

        try await withDependencies {
            $0.fsEventStreamClient.create = {
                allocator, callback, context, paths, sinceWhen, latency, flags in
                capturedCallback = callback
                capturedContext = context.pointee
                capturedPaths = paths
                capturedSinceWhen = sinceWhen
                capturedLatency = latency
                capturedFlags = flags
                return OpaquePointer(bitPattern: 1)
            }
            $0.fsEventStreamClient.setDispatchQueue = { ref, queue in
                setDispatchQueueCalled = true
                setDispatchQueueQueue = queue
            }
            $0.fsEventStreamClient.start = { _ in
                startCalled = true
                return true
            }
            $0.fsEventStreamClient.stop = { _ in
                stopCalled = true
            }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let paths = ["/tmp/test"]
            let task = Task {
                var receivedEvents: [[PathWatcherEvent]] = []
                do {
                    for try await events in client.events(
                        paths: paths, latency: 0.1, queue: nil, sinceWhen: nil, flags: nil)
                    {
                        receivedEvents.append(events)
                        break
                    }
                } catch {
                    Issue.record("Failed with error: \(error)")
                }
                #expect(receivedEvents.count == 1)
                #expect(receivedEvents.first?.count == 1)
                #expect(receivedEvents.first?.first?.path == "/tmp/event")
            }

            // Wait a bit for the stream to be set up
            try await Task.sleep(for: .milliseconds(10))

            // Simulate the callback being invoked
            if let callback = capturedCallback, let context = capturedContext {
                let eventPaths = ["/tmp/event"] as CFArray
                let eventFlags: [FSEventStreamEventFlags] = [
                    FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)
                ]
                let eventIds: [FSEventStreamEventId] = [1]

                eventFlags.withUnsafeBufferPointer { flagsPtr in
                    eventIds.withUnsafeBufferPointer { idsPtr in
                        guard let mockStreamRef = OpaquePointer(bitPattern: 1) else { return }
                        callback(
                            mockStreamRef,
                            context.info,
                            1,
                            Unmanaged.passUnretained(eventPaths).toOpaque(),
                            flagsPtr.baseAddress!,
                            idsPtr.baseAddress!
                        )
                    }
                }
            }

            try await Task.sleep(for: .milliseconds(50))
            task.cancel()
            try await Task.sleep(for: .milliseconds(50))

            #expect(capturedCallback != nil)
            #expect(capturedContext != nil)
            #expect(capturedPaths != nil)
            #expect(capturedSinceWhen != nil)
            #expect(capturedLatency != nil)
            #expect(capturedFlags != nil)
            #expect(setDispatchQueueCalled)
            #expect(setDispatchQueueQueue != nil)
            #expect(startCalled)
            #expect(stopCalled)
        }
    }

    @Test
    func `events, with stream creation failure, should throw streamCreationFailed`() async throws {
        await withDependencies {
            $0.fsEventStreamClient.create = { _, _, _, _, _, _, _ in nil }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            var didThrow = false
            var thrownError: PathWatcherError?

            do {
                for try await _ in client.events(
                    paths: ["/tmp"], latency: 0.1, queue: nil, sinceWhen: nil, flags: nil)
                {
                    Issue.record("Should have thrown for stream creation failure")
                    break
                }
            } catch let error as PathWatcherError {
                didThrow = true
                thrownError = error
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }

            #expect(didThrow)
            #expect(thrownError == .streamCreationFailed)
        }
    }

    @Test
    func `events, with stream start failure, should throw streamStartFailed`() async throws {
        await withDependencies {
            $0.fsEventStreamClient.create = { _, _, _, _, _, _, _ in
                // Return a mock pointer
                return OpaquePointer(bitPattern: 1)
            }
            $0.fsEventStreamClient.setDispatchQueue = { _, _ in }
            $0.fsEventStreamClient.start = { _ in false }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            var didThrow = false
            var thrownError: PathWatcherError?

            do {
                for try await _ in client.events(
                    paths: ["/tmp"], latency: 0.1, queue: nil, sinceWhen: nil, flags: nil)
                {
                    Issue.record("Should have thrown for stream start failure")
                    break
                }
            } catch let error as PathWatcherError {
                didThrow = true
                thrownError = error
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }

            #expect(didThrow)
            #expect(thrownError == .streamStartFailed)
        }
    }

    @Test
    func `events, when cancelled, should call stop`() async throws {
        nonisolated(unsafe) var stopCalled = false
        nonisolated(unsafe) var mockRef: FSEventStreamRef?

        try await withDependencies {
            $0.fsEventStreamClient.create = { _, _, _, _, _, _, _ in
                mockRef = OpaquePointer(bitPattern: 1)
                return mockRef
            }
            $0.fsEventStreamClient.setDispatchQueue = { _, _ in }
            $0.fsEventStreamClient.start = { _ in true }
            $0.fsEventStreamClient.stop = { ref in
                if ref == mockRef {
                    stopCalled = true
                }
            }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                for try await _ in client.events(
                    paths: ["/tmp"], latency: 0.1, queue: nil, sinceWhen: nil, flags: nil)
                {}
            }

            try await Task.sleep(for: .milliseconds(10))
            task.cancel()
            try await Task.sleep(for: .milliseconds(50))

            #expect(stopCalled)
        }
    }

    @Test
    func `events, with custom queue, should use provided queue`() async throws {
        let customQueue = DispatchQueue(label: "test.queue")
        nonisolated(unsafe) var capturedQueue: DispatchQueue?

        try await withDependencies {
            $0.fsEventStreamClient.create = { _, _, _, _, _, _, _ in
                OpaquePointer(bitPattern: 1)
            }
            $0.fsEventStreamClient.setDispatchQueue = { _, queue in
                capturedQueue = queue
            }
            $0.fsEventStreamClient.start = { _ in true }
            $0.fsEventStreamClient.stop = { _ in }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                for try await _ in client.events(
                    paths: ["/tmp"], latency: 0.1, queue: customQueue, sinceWhen: nil, flags: nil)
                {}
            }

            try await Task.sleep(for: .milliseconds(10))
            task.cancel()

            #expect(capturedQueue === customQueue)
        }
    }

    @Test
    func `events, with custom sinceWhen, should use provided sinceWhen`() async throws {
        let customSinceWhen = PathWatcherEvent.ID(100)
        nonisolated(unsafe) var capturedSinceWhen: FSEventStreamEventId?

        try await withDependencies {
            $0.fsEventStreamClient.create = { _, _, _, _, sinceWhen, _, _ in
                capturedSinceWhen = sinceWhen
                return OpaquePointer(bitPattern: 1)
            }
            $0.fsEventStreamClient.setDispatchQueue = { _, _ in }
            $0.fsEventStreamClient.start = { _ in true }
            $0.fsEventStreamClient.stop = { _ in }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                for try await _ in client.events(
                    paths: ["/tmp"], latency: 0.1, queue: nil, sinceWhen: customSinceWhen,
                    flags: nil)
                {}
            }

            try await Task.sleep(for: .milliseconds(10))
            task.cancel()

            #expect(capturedSinceWhen == customSinceWhen)
        }
    }

    @Test
    func `events, with custom flags, should use provided flags`() async throws {
        let customFlags = PathWatcherFlag.fileEvents
        nonisolated(unsafe) var capturedFlags: FSEventStreamCreateFlags?

        try await withDependencies {
            $0.fsEventStreamClient.create = { _, _, _, _, _, _, flags in
                capturedFlags = flags
                return OpaquePointer(bitPattern: 1)
            }
            $0.fsEventStreamClient.setDispatchQueue = { _, _ in }
            $0.fsEventStreamClient.start = { _ in true }
            $0.fsEventStreamClient.stop = { _ in }
            $0.pathWatcherClient = PathWatcherClient.liveValue
        } operation: {
            @Dependency(\.pathWatcherClient) var client

            let task = Task {
                for try await _ in client.events(
                    paths: ["/tmp"], latency: 0.1, queue: nil, sinceWhen: nil, flags: customFlags)
                {}
            }

            try await Task.sleep(for: .milliseconds(10))
            task.cancel()

            // Should include useCFTypes flag
            let expectedFlags = customFlags.union(.useCFTypes).rawValue
            #expect(capturedFlags == expectedFlags)
        }
    }
}
