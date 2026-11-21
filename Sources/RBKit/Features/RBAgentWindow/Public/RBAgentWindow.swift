import AppKit

open class RBAgentWindow: NSPanel {

  // MARK: Lifecycle

  public override init(
    contentRect: NSRect,
    styleMask style: NSWindow.StyleMask,
    backing backingStoreType: NSWindow.BackingStoreType,
    defer flag: Bool,
  ) {
    super.init(
      contentRect: contentRect,
      styleMask: style.union([.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel]),
      backing: backingStoreType,
      defer: flag,
    )

    // Configuring the Window's Appearance
    // -----------------------------------
    // NEVER add `.utilityWindow` to the style mask as it creates severe issues with full-screen apps.
    hidesOnDeactivate = false
    // like alt-tab's `collectionBehavior`: https://github.com/lwouis/alt-tab-macos/blob/8152c3cebf0091385d8ec8d54aeefd805477d864/src/ui/main-window/ThumbnailsPanel.swift#L18
    collectionBehavior = [
      // STAGE MANAGER AND FULL SCREEN:
      // primary
      // auxiliary
      // canJoinAllApplications

      // SPACES:
      .canJoinAllSpaces
      // .moveToActiveSpace,

      // MISSION CONTROL:
      // .stationary

      // SPACES AND MISSION CONTROL:
      // .managed
      // .transient,

      // FULL SCREEN:
      // .fullScreenPrimary,
      // .fullScreenAuxiliary,
      // .fullScreenNone,
      // .fullScreenAllowsTiling,
      // .fullScreenDisallowsTiling

      // WINDOW CYCLING
      // .participatesInCycle
      // .ignoresCycle
    ]

    // Managing Window Layers
    // ----------------------
    level = .floating

    // Managing Title Bars
    // -------------------
    standardWindowButton(.miniaturizeButton)?.isHidden = true
    standardWindowButton(.zoomButton)?.isHidden = true
    standardWindowButton(.closeButton)?.isHidden = true
    titlebarAppearsTransparent = true

    // Window Animation
    // ----------------
    animationBehavior = .utilityWindow

    // Managing Titles
    // ---------------
    titleVisibility = .hidden

    // Moving Windows
    // --------------
    isMovableByWindowBackground = true

    // Closing Windows
    // ---------------
    isReleasedWhenClosed = false // When specify this explicitly in case this class will be owned by an NSWindowController

    // NSPanel stuff
    // -------------
    isFloatingPanel = true
  }

  // MARK: Open

  open override var canBecomeKey: Bool {
    true
  }

  open override var canBecomeMain: Bool {
    true
  }
}
