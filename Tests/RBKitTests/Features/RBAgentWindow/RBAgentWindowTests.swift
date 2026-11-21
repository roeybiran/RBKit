import AppKit
import Testing

@testable import RBKit

// MARK: - RBAgentWindowTests

@MainActor
struct RBAgentWindowTests {

  @Test
  func `init should configure window appearance properties`() {
    let window = RBAgentWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
      styleMask: [],
      backing: .buffered,
      defer: false,
    )

    // Style mask should include required styles
    #expect(window.styleMask.contains(.titled))
    #expect(window.styleMask.contains(.closable))
    #expect(window.styleMask.contains(.resizable))
    #expect(window.styleMask.contains(.fullSizeContentView))
    #expect(window.styleMask.contains(.nonactivatingPanel))

    // Window appearance configuration
    #expect(!window.hidesOnDeactivate)
    #expect(window.collectionBehavior == .canJoinAllSpaces)
    #expect(window.level == .floating)

    // Title bar configuration
    #expect(window.standardWindowButton(.miniaturizeButton)?.isHidden == true)
    #expect(window.standardWindowButton(.zoomButton)?.isHidden == true)
    #expect(window.standardWindowButton(.closeButton)?.isHidden == true)
    #expect(window.titlebarAppearsTransparent)
    #expect(window.titleVisibility == .hidden)

    // Other window properties
    #expect(window.animationBehavior == .utilityWindow)
    #expect(window.isMovableByWindowBackground)
    #expect(!window.isReleasedWhenClosed)
    #expect(window.isFloatingPanel)
  }

  @Test
  func `canBecomeKey should return true`() {
    let window = RBAgentWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
      styleMask: [],
      backing: .buffered,
      defer: false,
    )

    #expect(window.canBecomeKey)
  }

  @Test
  func `canBecomeMain should return true`() {
    let window = RBAgentWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
      styleMask: [],
      backing: .buffered,
      defer: false,
    )

    #expect(window.canBecomeMain)
  }

  @Test
  func `init should preserve provided contentRect`() {
    let contentRect = NSRect(x: 100, y: 200, width: 800, height: 600)
    let window = RBAgentWindow(
      contentRect: contentRect,
      styleMask: [],
      backing: .buffered,
      defer: false,
    )

    #expect(window.frame.size.width == contentRect.width)
    #expect(window.frame.size.height == contentRect.height)
  }

  @Test
  func `init should combine provided styleMask with required styles`() {
    let customStyle: NSWindow.StyleMask = [.borderless]
    let window = RBAgentWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
      styleMask: customStyle,
      backing: .buffered,
      defer: false,
    )

    // Should include custom style
    #expect(window.styleMask.contains(.borderless))

    // Should also include required styles
    #expect(window.styleMask.contains(.titled))
    #expect(window.styleMask.contains(.closable))
    #expect(window.styleMask.contains(.resizable))
    #expect(window.styleMask.contains(.fullSizeContentView))
    #expect(window.styleMask.contains(.nonactivatingPanel))
  }
}
