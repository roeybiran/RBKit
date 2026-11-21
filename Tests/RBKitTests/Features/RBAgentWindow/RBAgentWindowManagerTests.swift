import Cocoa
import Dependencies
import Sharing
import Testing

@testable import RBKit

// MARK: - RBAgentWindowManagerTests

@MainActor
struct RBAgentWindowManagerTests {

  @Test
  func `getTopLeftPoint with no Defaults key should fallback to the main screen`() {
    seedRBAgentWindowState(xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      let preferredScreen = Screen.mock(x: -1728, y: 1440, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
    #expect(topLeftPoint == CGPoint(x: -1104, y: 1979.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at top left with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      let preferredScreen = Screen.mock(x: -1728, y: 1440, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
    #expect(topLeftPoint == CGPoint(x: -1104, y: 1979.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at top right with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      let preferredScreen = Screen.mock(x: 2560, y: 1440, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
    #expect(topLeftPoint == CGPoint(x: 3184, y: 1979.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at bottom left with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
      let preferredScreen = Screen.mock(x: -1728, y: -1117, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == CGPoint(x: -1104, y: -577.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at bottom right with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
      let preferredScreen = Screen.mock(x: 2560, y: -1117, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == CGPoint(x: 3184, y: -577.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at top with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
      let preferredScreen = Screen.mock(x: 0, y: 1440, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == CGPoint(x: 624, y: 1979.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at bottom with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
      let preferredScreen = Screen.mock(x: 832, y: -1117, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == CGPoint(x: 1456, y: -577.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at left with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
      let preferredScreen = Screen.mock(x: -1728, y: 323, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == CGPoint(x: -1104, y: 862.5))
  }

  @Test
  func `getTopLeftPoint with preferred screen at right with saved coordinates should move to screen`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus, xFraction: 0.5, yFraction: 0.5)

    let topLeftPoint = withDependencies { d in
      // current screen is e.g. -> Screen.mock(x: 0, y: 0, w: 2560, h: 1415) // "DELL P2421DC"
      let preferredScreen = Screen.mock(x: 2560, y: 0, w: 1728, h: 1079) // "Built-in Retina Display"
      d.screenClient.main = { preferredScreen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == CGPoint(x: 3184, y: 539.5))
  }

  @Test
  func `getTopLeftPoint with mouse cursor preference with saved coordinates should set origin`() async {
    seedRBAgentWindowState(preferredScreen: .withMouseCursor, xFraction: 0.5, yFraction: 0.5)

    let center = NotificationCenter()
    let currentScreen = Screen.mock(x: 0, y: 0, w: 1920, h: 1080)
    let preferredScreen = Screen.mock(x: -1920, y: -1080, w: 1920, h: 1080)
    let mouseLocation = CGPoint(
      x: preferredScreen.visibleFrame.midX,
      y: preferredScreen.visibleFrame.midY,
    )
    let screens = [currentScreen, preferredScreen]
    let manager = withDependencies { d in
      d.notificationCenter = center
      d.screenClient.screens = { screens }
      d.nsEventClient.mouseLocation = { mouseLocation }
    } operation: { RBAgentWindowManager() }

    try? await Task.sleep(for: TEST_SLEEP_DURATION)
    center.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
    var topLeftPoint = manager.getTopLeftPoint(currentFrame: TEST_FRAME)
    for _ in 1...10 {
      if topLeftPoint == CGPoint(x: -1200, y: -540) { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
      topLeftPoint = manager.getTopLeftPoint(currentFrame: TEST_FRAME)
    }

    #expect(topLeftPoint == CGPoint(x: -1200, y: -540))
  }

  @Test
  func `getTopLeftPoint with preferred screen 2 screens to the left with saved coordinates should move to screen`() async {
    seedRBAgentWindowState(preferredScreen: .withMouseCursor, xFraction: 0.5, yFraction: 0.5)

    let center = NotificationCenter()
    let manager = withDependencies { d in
      d.notificationCenter = center
      // 3 screens to the left
      let screens = [
        Screen.mock(x: 0, y: 0, w: 1728, h: 1079), // "Built-in Retina Display"
        Screen.mock(x: -2560, y: -323, w: 2560, h: 1415), // "DELL P2421DC (2)"
        Screen.mock(x: -5120, y: -323, w: 2560, h: 1415), // "DELL P2421DC (1)"
      ]

      d.screenClient.screens = { screens }
      d.nsEventClient.mouseLocation = {
        CGPoint(x: screens[2].visibleFrame.midX, y: screens[2].visibleFrame.midY)
      }
    } operation: { RBAgentWindowManager() }

    try? await Task.sleep(for: TEST_SLEEP_DURATION)
    center.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
    var topLeftPoint = manager.getTopLeftPoint(currentFrame: TEST_FRAME)
    for _ in 1...10 {
      if topLeftPoint == CGPoint(x: -4080, y: 384.5) { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
      topLeftPoint = manager.getTopLeftPoint(currentFrame: TEST_FRAME)
    }

    #expect(topLeftPoint == CGPoint(x: -4080, y: 384.5))
  }

  @Test
  func `get top left point with preferred screen2 screens to the right with saved coords should move to screen`() async {
    seedRBAgentWindowState(preferredScreen: .withMouseCursor, xFraction: 0.5, yFraction: 0.5)

    let center = NotificationCenter()
    let manager = withDependencies { d in
      d.notificationCenter = center
      // 3 screens to the right
      let screens = [
        Screen.mock(x: 0, y: 0, w: 1728, h: 1079), // "Built-in Retina Display"
        Screen.mock(x: 1728, y: -323, w: 2560, h: 1415), // "DELL P2421DC (1)"
        Screen.mock(x: 4288, y: -323, w: 2560, h: 1415), // "DELL P2421DC (2)"
      ]
      d.screenClient.screens = { screens }
      d.nsEventClient.mouseLocation = {
        CGPoint(x: screens[1].visibleFrame.midX, y: screens[1].visibleFrame.midY)
      }
    } operation: { RBAgentWindowManager() }

    try? await Task.sleep(for: TEST_SLEEP_DURATION)
    center.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
    var topLeftPoint = manager.getTopLeftPoint(currentFrame: TEST_FRAME)
    for _ in 1...10 {
      if topLeftPoint == CGPoint(x: 2768, y: 384.5) { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
      topLeftPoint = manager.getTopLeftPoint(currentFrame: TEST_FRAME)
    }

    #expect(topLeftPoint == CGPoint(x: 2768, y: 384.5))
  }

  @Test
  func `getTopLeftPoint with menu bar preference with saved coordinates should switch to the screen`() async {
    seedRBAgentWindowState(preferredScreen: .withMenuBar, xFraction: 0.5, yFraction: 0.5)

    let center = NotificationCenter()
    let manager = withDependencies { d in
      d.notificationCenter = center

      let screens = [
        Screen.mock(x: 0, y: 0, w: 1920, h: 1080),
        Screen.mock(x: 1920, y: 0, w: 1920, h: 1080),
        Screen.mock(x: 3840, y: 0, w: 1920, h: 1080),
      ]

      d.screenClient.screens = { screens }
    } operation: { RBAgentWindowManager() }

    try? await Task.sleep(for: TEST_SLEEP_DURATION)
    center.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
    var topLeftPoint = manager.getTopLeftPoint(
      currentFrame: CGRect(x: 0, y: 0, width: 480, height: 270)
    )
    for _ in 1...10 {
      if topLeftPoint == CGPoint(x: 720, y: 540) { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
      topLeftPoint = manager.getTopLeftPoint(
        currentFrame: CGRect(x: 0, y: 0, width: 480, height: 270)
      )
    }

    #expect(topLeftPoint == CGPoint(x: 720, y: 540))
  }

  @Test
  func `getPreferredScreen should refresh cached screens after screen params change`() async {
    seedRBAgentWindowState(preferredScreen: .withMenuBar)

    let center = NotificationCenter()
    let initialScreen = Screen.mock(x: 0, y: 0, w: 1920, h: 1080)
    let updatedScreen = Screen.mock(x: 1920, y: 0, w: 1920, h: 1080)
    nonisolated(unsafe) var screens = [initialScreen]

    let manager = withDependencies { d in
      d.notificationCenter = center
      d.screenClient.main = { screens.first }
      d.screenClient.screens = { screens }
    } operation: {
      RBAgentWindowManager()
    }

    #expect(manager.getPreferredScreen() == nil)

    try? await Task.sleep(for: TEST_SLEEP_DURATION)
    center.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
    for _ in 1...10 {
      if manager.getPreferredScreen() == initialScreen { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
    }
    #expect(manager.getPreferredScreen() == initialScreen)

    screens = [updatedScreen]
    center.post(name: NSApplication.didChangeScreenParametersNotification, object: nil)
    for _ in 1...10 {
      if manager.getPreferredScreen() == updatedScreen { break }
      try? await Task.sleep(for: TEST_SLEEP_DURATION)
    }

    #expect(manager.getPreferredScreen() == updatedScreen)
  }

  @Test
  func `getTopLeftPoint on preferred screen without saved coordinates should nullify origin`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus)

    let topLeftPoint = withDependencies { d in
      let screen = Screen.mock(x: 0, y: 0, w: 1920, h: 1080)
      d.screenClient.main = { screen }
    } operation: { RBAgentWindowManager().getTopLeftPoint(currentFrame: TEST_FRAME) }

    #expect(topLeftPoint == nil)
  }

  @Test
  func `getTopLeftPoint on non-preferred screen without saved coordinates should nullify origin`() {
    seedRBAgentWindowState(preferredScreen: .withKeyboardFocus)

    let topLeftPoint = withDependencies { d in
      let preferredScreen = Screen.mock(x: 1920, y: 0, w: 1920, h: 1080)
      d.screenClient.main = { preferredScreen }
    } operation: {
      RBAgentWindowManager().getTopLeftPoint(
        currentFrame: CGRect(origin: .zero, size: CGSize(width: 480, height: 270))
      )
    }

    #expect(topLeftPoint == nil)
  }

  @Test
  func `getTopLeftPoint with preferred screen not found should nullify origin`() {
    seedRBAgentWindowState(preferredScreen: .withMenuBar)

    let topLeftPoint = withDependencies { d in
      d.screenClient.screens = { [] }
      d.screenClient.main = { nil }
    } operation: {
      RBAgentWindowManager().getTopLeftPoint(
        currentFrame: CGRect(origin: .zero, size: CGSize(width: 480, height: 270))
      )
    }

    #expect(topLeftPoint == nil)
  }

  @Test
  func `setTopLeftPoint at a screen to left should register new coordinates`() {
    @Shared(.rbAgentWindowOriginXFraction) var windowOriginXFraction = 0.0
    @Shared(.rbAgentWindowOriginYFraction) var windowOriginYFraction = 0.0
    let screen = Screen.mock(x: -1920, y: -1080, w: 1920, h: 1080) // bottom left screen
    let window = CGRect(x: -1200, y: -540, width: 480, height: 270)

    RBAgentWindowManager().setTopLeftPoint(currentFrame: window, currentScreen: screen)

    #expect(windowOriginXFraction == 0.5)
    #expect(windowOriginYFraction == 0.25)
  }

  @Test
  func `setTopLeftPoint at a screen to the right should register new coordinates`() {
    @Shared(.rbAgentWindowOriginXFraction) var windowOriginXFraction = 0.0
    @Shared(.rbAgentWindowOriginYFraction) var windowOriginYFraction = 0.0
    let screen = Screen.mock(x: 3840, y: 1080, w: 1920, h: 1080) // bottom left screen
    let window = CGRect(x: 4560, y: 1620, width: 480, height: 270)

    RBAgentWindowManager().setTopLeftPoint(currentFrame: window, currentScreen: screen)

    #expect(windowOriginXFraction == 0.5)
    #expect(windowOriginYFraction == 0.25)
  }

  @Test
  func `setTopLeftPoint at center of current screen should register new coordinates`() {
    @Shared(.rbAgentWindowOriginXFraction) var windowOriginXFraction = 0.0
    @Shared(.rbAgentWindowOriginYFraction) var windowOriginYFraction = 0.0
    let screen = Screen.mock(x: 1920, y: 0, w: 1920, h: 1080)
    let window = CGRect(x: 2640, y: 615.6, width: TEST_FRAME.width, height: TEST_FRAME.height)

    RBAgentWindowManager().setTopLeftPoint(currentFrame: window, currentScreen: screen)

    #expect(windowOriginXFraction == 0.5)
    #expect(abs(0.18 - windowOriginYFraction) <= 0.1)
  }

  @Test
  func `setTopLeftPoint at the same location should save coordinates`() {
    @Shared(.rbAgentWindowOriginXFraction) var windowOriginXFraction = 0.0
    @Shared(.rbAgentWindowOriginYFraction) var windowOriginYFraction = 0.0
    let screen = Screen.mock(x: 0, y: 0, w: 1920, h: 1080)
    let window = CGRect(x: 720, y: 270, width: 480, height: 270)

    RBAgentWindowManager().setTopLeftPoint(currentFrame: window, currentScreen: screen)

    #expect(windowOriginXFraction == 0.5)
    #expect(windowOriginYFraction == 0.5)
  }
}

private func seedRBAgentWindowState(
  preferredScreen: PreferredScreen = .withKeyboardFocus,
  xFraction: Double = 0,
  yFraction: Double = 0,
) {
  @Shared(.rbAgentWindowPreferredScreen) var storedPreferredScreen = .withKeyboardFocus
  @Shared(.rbAgentWindowOriginXFraction) var storedWindowOriginXFraction = 0.0
  @Shared(.rbAgentWindowOriginYFraction) var storedWindowOriginYFraction = 0.0

  $storedPreferredScreen.withLock {
    $0 = preferredScreen
  }
  $storedWindowOriginXFraction.withLock {
    $0 = xFraction
  }
  $storedWindowOriginYFraction.withLock {
    $0 = yFraction
  }
}

extension Screen {
  static func mock(x: Double = 0, y: Double = 0, w: Double = 0, h: Double = 0) -> Self {
    Screen.mock(visibleFrame: CGRect(x: x, y: y, width: w, height: h))
  }
}

let TEST_FRAME = CGRect(
  origin: NSPoint(x: 1920 / 4, y: 1080 / 4),
  size: CGSize(width: 480, height: 270),
)
