import Dependencies
import DependenciesMacros
import Foundation

// MARK: - RBAgentWindowManagerClient

@DependencyClient
public struct RBAgentWindowManagerClient: Sendable {
  public var getPreferredScreen: @MainActor @Sendable () -> Screen?
  public var setTopLeftPoint:
    @MainActor @Sendable (_ currentFrame: CGRect, _ currentScreen: Screen) -> Void
  public var getTopLeftPoint: @MainActor @Sendable (_ currentFrame: CGRect) -> CGPoint?
}

// MARK: DependencyKey

extension RBAgentWindowManagerClient: DependencyKey {

  // MARK: Public

  public static let liveValue = {
    // Run migration before creating manager
    migrateToRBAgentWindowV2()

    return Self(
      getPreferredScreen: { manager.getPreferredScreen() },
      setTopLeftPoint: { manager.setTopLeftPoint(currentFrame: $0, currentScreen: $1) },
      getTopLeftPoint: { manager.getTopLeftPoint(currentFrame: $0) },
    )
  }()

  public static let testValue = Self()

  // MARK: Private

  @MainActor private static let manager = RBAgentWindowManager()
}

extension DependencyValues {
  public var rbAgentWindowManagerClient: RBAgentWindowManagerClient {
    get { self[RBAgentWindowManagerClient.self] }
    set { self[RBAgentWindowManagerClient.self] = newValue }
  }
}
