import AppKit
import Dependencies
import Foundation
import Sharing

@MainActor
final class RBAgentWindowManager {

  // MARK: Lifecycle

  init() {
    let notification = NSApplication.didChangeScreenParametersNotification
    let notificationCenter = notificationCenter
    let screenClient = screenClient
    screenUpdatesTask = Task { [weak self] in
      guard let self else { return }
      for await _ in notificationCenter.notifications(named: notification) {
        screens = screenClient.screens()
      }
    }
  }

  deinit {
    screenUpdatesTask?.cancel()
  }

  // MARK: Internal

  @Dependency(\.nsEventClient) var nsEventClient
  @Dependency(\.notificationCenter) var notificationCenter
  @Dependency(\.screenClient) var screenClient

  func getPreferredScreen() -> Screen? {
    switch preferredScreen {
    case .withMouseCursor:
      let mouseLocation = nsEventClient.mouseLocation()
      return screens.first { $0.visibleFrame.contains(mouseLocation) }

    case .withMenuBar:
      return screens.first

    case .withKeyboardFocus:
      return screenClient.main()
    }
  }

  func setTopLeftPoint(currentFrame: CGRect, currentScreen: Screen) {
    let screenRelativeWindowX = currentFrame.midX - currentScreen.visibleFrame.minX
    let screenRelativeWindowY = currentFrame.maxY - currentScreen.visibleFrame.maxY
    let xFraction = abs(screenRelativeWindowX / currentScreen.visibleFrame.width)
    let yFraction = abs(screenRelativeWindowY / currentScreen.visibleFrame.height)
    $windowOriginXFraction.withLock {
      $0 = xFraction
    }
    $windowOriginYFraction.withLock {
      $0 = yFraction
    }
  }

  func getTopLeftPoint(currentFrame: CGRect) -> CGPoint? {
    let windowHalfWidth = currentFrame.width / 2

    guard let targetScreen = getPreferredScreen() else {
      return nil
    }

    guard windowOriginXFraction > 0, windowOriginYFraction > 0 else {
      return nil
    }

    let targetScreenX = targetScreen.visibleFrame.minX
    let targetScreenY = targetScreen.visibleFrame.maxY
    let targetScreenW = targetScreen.visibleFrame.width
    let targetScreenH = targetScreen.visibleFrame.height

    let finalX = (targetScreenX + (targetScreenW * windowOriginXFraction)) - windowHalfWidth
    let finalY = targetScreenY - (targetScreenH * windowOriginYFraction)

    return CGPoint(x: finalX, y: finalY)
  }

  // MARK: Private

  private var screens = [Screen]()
  private var screenUpdatesTask: Task<Void, Never>?
  @Shared(.rbAgentWindowPreferredScreen) private var preferredScreen = .withKeyboardFocus
  @Shared(.rbAgentWindowOriginXFraction) private var windowOriginXFraction = 0.0
  @Shared(.rbAgentWindowOriginYFraction) private var windowOriginYFraction = 0.0

}
