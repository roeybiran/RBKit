import Dependencies
import Testing
@testable import RBKit

struct TextInputSourcesClientKeyTests {
  @Test
  func `TextInputSourcesClientKey values should expose live and test implementations`() {
    #expect(TextInputSourcesClientKey.liveValue is TextInputSourcesClientLive)
    #expect(TextInputSourcesClientKey.testValue is TextInputSourcesClientMock)
  }

  @Test
  func `DependencyValues textInputSourcesClient should support override and access`() {
    let expectedClient = TextInputSourcesClientMock()

    let actualClient = withDependencies {
      $0.textInputSourcesClient = expectedClient
    } operation: { () -> TextInputSourcesClientMock? in
      @Dependency(\.textInputSourcesClient) var textInputSourcesClient
      return textInputSourcesClient as? TextInputSourcesClientMock
    }

    #expect(actualClient === expectedClient)
  }
}
