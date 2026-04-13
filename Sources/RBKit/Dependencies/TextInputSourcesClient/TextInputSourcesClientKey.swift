import Dependencies

// MARK: - TextInputSourcesClientKey

public enum TextInputSourcesClientKey: DependencyKey {
  public static let liveValue: any TextInputSourcesClientProtocol = TextInputSourcesClientLive()
  public static let testValue: any TextInputSourcesClientProtocol = TextInputSourcesClientMock()
}

extension DependencyValues {
  public var textInputSourcesClient: any TextInputSourcesClientProtocol {
    get { self[TextInputSourcesClientKey.self] }
    set { self[TextInputSourcesClientKey.self] = newValue }
  }
}
