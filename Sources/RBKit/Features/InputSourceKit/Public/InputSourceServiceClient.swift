import Dependencies
import DependenciesMacros

// MARK: - InputSourceServiceClient

@DependencyClient
public struct InputSourceServiceClient: Sendable {
  public var start: @Sendable @MainActor () -> AsyncStream<[InputSource]> = { .init { $0.finish() } }
  public var getPreferredInputSource: @Sendable @MainActor () -> InputSource? = { nil }
  public var setPreferredInputSource: @Sendable @MainActor (_ source: InputSource?) -> Void = { _ in }
  public var activatePreferredSource: @Sendable @MainActor () -> Void = { }
  public var restorePreviousSource: @Sendable @MainActor () -> Void = { }
}

// MARK: nonisolated

extension InputSourceServiceClient: nonisolated DependencyKey {

  // MARK: Public

  public static let liveValue = Self(
    start: { service.start() },
    getPreferredInputSource: { service.getPreferredInputSource() },
    setPreferredInputSource: { service.setPreferredInputSource($0) },
    activatePreferredSource: { service.activatePreferredSource() },
    restorePreviousSource: { service.restorePreviousSource() },
  )

  public static let testValue = Self()

  // MARK: Internal

  @MainActor static let service = InputSourceService(textInputSourcesClient: TextInputSourcesClientLive())

}

extension DependencyValues {
  public var inputSourceServiceClient: InputSourceServiceClient {
    get { self[InputSourceServiceClient.self] }
    set { self[InputSourceServiceClient.self] = newValue }
  }
}
