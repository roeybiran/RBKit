@preconcurrency import Carbon
import Dependencies
import Foundation
import Sharing
import Testing
@testable import RBKit

@MainActor
struct InputSourceServiceClientTests {

  @Test
  func `liveValue-style closure wiring, should forward write and start endpoints`() async {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, _) = makeTextInputSourcesClientMock(sources: [sourceB, sourceA], currentSourceID: nil)

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = nil
    let service = makeService(textInputSourcesClient: textInputSourcesClient)
    let sut = InputSourceServiceClient(
      start: { service.start() },
      getPreferredInputSource: { service.getPreferredInputSource() },
      setPreferredInputSource: { service.setPreferredInputSource($0) },
      activatePreferredSource: { service.activatePreferredSource() },
      restorePreviousSource: { service.restorePreviousSource() },
    )

    var observer = sut.start().makeAsyncIterator()
    #expect(await observer.next() == [sourceA, sourceB])

    sut.setPreferredInputSource(sourceB)
    #expect(preferredInputSourceID == sourceB.id)
    #expect(sut.getPreferredInputSource() == sourceB)

    sut.setPreferredInputSource(nil)
    #expect(preferredInputSourceID == nil)
    #expect(sut.getPreferredInputSource() == nil)
  }

  @Test
  func `liveValue-style closure wiring, should forward activate and restore endpoints`() {
    let sourceA = InputSource(id: "a", name: "A")
    let sourceB = InputSource(id: "b", name: "B")
    let (textInputSourcesClient, sourceRefByID) = makeTextInputSourcesClientMock(
      sources: [sourceA, sourceB],
      currentSourceID: sourceA.id,
    )
    let sourceIDByRef = Dictionary(uniqueKeysWithValues: sourceRefByID.map { (ObjectIdentifier($1), $0) })

    nonisolated(unsafe) var selectedSourceIDs = [String]()
    textInputSourcesClient.TISSelectInputSourceHandler = { inputSource in
      if let sourceID = sourceIDByRef[ObjectIdentifier(inputSource)] {
        selectedSourceIDs.append(sourceID)
      }

      return noErr
    }

    @Shared(.preferredInputSourceID) var preferredInputSourceID: InputSource.ID? = sourceB.id
    let service = makeService(textInputSourcesClient: textInputSourcesClient)
    let sut = InputSourceServiceClient(
      start: { service.start() },
      getPreferredInputSource: { service.getPreferredInputSource() },
      setPreferredInputSource: { service.setPreferredInputSource($0) },
      activatePreferredSource: { service.activatePreferredSource() },
      restorePreviousSource: { service.restorePreviousSource() },
    )

    _ = sut.start()
    sut.activatePreferredSource()
    sut.restorePreviousSource()

    #expect(selectedSourceIDs == [sourceB.id, sourceA.id])
  }

  @Test
  func `inputSourceServiceClient dependency value, should support override and preferred input source access`() {
    let sourceA = InputSource(id: "a", name: "A")
    nonisolated(unsafe) var preferredInputSource: InputSource?
    let expectedClient = InputSourceServiceClient(
      start: { .init { $0.finish() } },
      getPreferredInputSource: { preferredInputSource },
      setPreferredInputSource: { preferredInputSource = $0 },
      activatePreferredSource: { },
      restorePreviousSource: { },
    )

    let result = withDependencies {
      $0.inputSourceServiceClient = expectedClient
    } operation: { () -> InputSource? in
      @Dependency(\.inputSourceServiceClient) var inputSourceServiceClient
      inputSourceServiceClient.setPreferredInputSource(sourceA)
      return inputSourceServiceClient.getPreferredInputSource()
    }

    #expect(result == sourceA)
  }

  @Test
  func `inputSourceServiceClient dependency value, should support start override`() async {
    let sourceA = InputSource(id: "a", name: "A")
    let expectedClient = InputSourceServiceClient(
      start: {
        AsyncStream { continuation in
          continuation.yield([sourceA])
          continuation.finish()
        }
      },
      getPreferredInputSource: { nil },
      setPreferredInputSource: { _ in },
      activatePreferredSource: { },
      restorePreviousSource: { },
    )

    let client = withDependencies {
      $0.inputSourceServiceClient = expectedClient
    } operation: { () -> InputSourceServiceClient in
      @Dependency(\.inputSourceServiceClient) var inputSourceServiceClient
      return inputSourceServiceClient
    }

    var observer = client.start().makeAsyncIterator()
    #expect(await observer.next() == [sourceA])
  }

  @Test
  func `InputSourceServiceClient liveValue, should provide sorted input sources`() async throws {
    let sut = InputSourceServiceClient.liveValue
    var observer = sut.start().makeAsyncIterator()
    let sources = try #require(await observer.next())
    let sourceNames = sources.map(\.name)

    #expect(sourceNames == sourceNames.sorted())
  }
}
