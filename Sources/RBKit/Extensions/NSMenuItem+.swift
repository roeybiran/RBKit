import AppKit

@MainActor
extension NSMenuItem {

  // MARK: Lifecycle

  public convenience init(
    _ title: String,
    action: Selector? = nil,
    keyEquivalent: String = "",
    @MenuBuilder builder: () -> [NSMenuItem] = { [] },
  ) {
    self.init(title: title, action: action, keyEquivalent: keyEquivalent)
    let menu = NSMenu(title: title)
    menu.items = builder()
    submenu = menu
  }

  public convenience init(
    _ title: String,
    selector: Selector,
    target: AnyObject?,
    keyEquivalent: String = "",
    @MenuBuilder builder: () -> [NSMenuItem] = { [] },
  ) {
    self.init(title: title, action: selector, keyEquivalent: keyEquivalent)
    self.target = target
    let menu = NSMenu(title: title)
    menu.items = builder()
    submenu = menu
  }

  // MARK: Public

  public func withChildren(@MenuBuilder _ builder: () -> [NSMenuItem]) -> Self {
    assert(submenu != nil, "NSMenuItem.withChildren(_:) requires an existing submenu.")
    submenu?.items = builder()
    return self
  }

}

@MainActor
extension NSMenuItem {

  // MARK: - Application menu

  public static func applicationMenu(
    settingsAction: Selector?,
    settingsTarget: AnyObject?,
  ) -> NSMenuItem {
    NSMenuItem(String.appName) {
      about
      NSMenuItem.separator()
      settings(action: settingsAction, target: settingsTarget)
      NSMenuItem.separator()
      servicesMenu()
      NSMenuItem.separator()
      hide
      hideOthers
      showAll
      NSMenuItem.separator()
      quit
    }
  }

  public static let about = NSMenuItem.about(target: NSApplication.shared)

  public static func settings(
    action: Selector?,
    target: AnyObject?,
  ) -> NSMenuItem {
    let menuItem = NSMenuItem("Settings…", action: action, keyEquivalent: ",")
    menuItem.target = target
    menuItem.image = NSImage(systemSymbolName: "gear", accessibilityDescription: nil)
    return menuItem
  }

  public static func servicesMenu(app: NSApplication = .shared) -> NSMenuItem {
    let title = "Services"
    let menuItem = NSMenuItem(title)
    menuItem.submenu = NSMenu(title)
    app.servicesMenu = menuItem.submenu
    return menuItem
  }

  public static let hide = NSMenuItem(
    "Hide \(String.appName)",
    action: #selector(NSApplication.hide(_:)),
    keyEquivalent: "h",
  )

  public static let hideOthers = NSMenuItem(
    "Hide Others",
    action: #selector(NSApplication.hideOtherApplications(_:)),
    keyEquivalent: "h",
  )
  .set(\.keyEquivalentModifierMask, to: [.option, .command])

  public static let showAll = NSMenuItem(
    "Show All",
    action: #selector(NSApplication.unhideAllApplications(_:)),
  )

  public static let quit = NSMenuItem(
    "Quit \(String.appName)",
    action: #selector(NSApplication.terminate),
    keyEquivalent: "q",
  )
  .set(\.image, to: NSImage(systemSymbolName: "power", accessibilityDescription: nil))

  public static func about(
    selector: Selector = #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
    target: AnyObject?,
  ) -> NSMenuItem {
    NSMenuItem(
      "About \(String.appName)",
      selector: selector,
      target: target,
    )
    .set(\.image, to: NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil))
  }

}

@MainActor
extension NSMenuItem {

  // MARK: - File menu

  public static let fileMenu = NSMenuItem("File") {
    new
    open
    openRecent
    NSMenuItem.separator()
    close
    save
    saveAs
    revertToSaved
    NSMenuItem.separator()
    pageSetup
    print
  }

  public static let new = NSMenuItem(
    "New",
    action: #selector(NSDocumentController.newDocument(_:)),
    keyEquivalent: "n",
  )

  public static let open = NSMenuItem(
    "Open…",
    action: #selector(NSDocumentController.openDocument(_:)),
    keyEquivalent: "o",
  )

  public static let openRecent = NSMenuItem("Open Recent") {
    clearMenu
  }

  public static let clearMenu = NSMenuItem(
    "Clear Menu",
    action: #selector(NSDocumentController.clearRecentDocuments(_:)),
  )

  public static let close = NSMenuItem(
    "Close",
    action: #selector(NSWindow.performClose(_:)),
    keyEquivalent: "w",
  )

  public static let save = NSMenuItem(
    "Save…",
    action: #selector(NSDocument.save(_:)),
    keyEquivalent: "s",
  )

  public static let saveAs = NSMenuItem(
    "Save As…",
    action: #selector(NSDocument.saveAs(_:)),
    keyEquivalent: "S",
  )

  public static let revertToSaved = NSMenuItem(
    "Revert to Saved",
    action: #selector(NSDocument.revertToSaved(_:)),
    keyEquivalent: "r",
  )

  public static let pageSetup = NSMenuItem(
    "Page Setup…",
    action: #selector(NSDocument.runPageLayout(_:)),
    keyEquivalent: "P",
  )

  public static let print = NSMenuItem(
    "Print…",
    action: #selector(NSDocument.printDocument(_:)),
    keyEquivalent: "p",
  )

}

@MainActor
extension NSMenuItem {

  // MARK: - Edit menu

  public static let editMenu = NSMenuItem("Edit") {
    undo
    redo
    NSMenuItem.separator()
    cut
    copy
    paste
    pasteAndMatchStyle
    delete
    selectAll
    NSMenuItem.separator()
    findMenu
    spellingAndGrammar
    substitutions
    transformations
    speech
  }

  public static let undo = NSMenuItem(
    "Undo",
    action: #selector(UndoManager.undo),
    keyEquivalent: "z",
  )

  public static let redo = NSMenuItem(
    "Redo",
    action: #selector(UndoManager.redo),
    keyEquivalent: "Z",
  )

  public static let cut = NSMenuItem(
    "Cut",
    action: #selector(NSText.cut(_:)),
    keyEquivalent: "x",
  )

  public static let copy = NSMenuItem(
    "Copy",
    action: #selector(NSText.copy(_:)),
    keyEquivalent: "c",
  )

  public static let paste = NSMenuItem(
    "Paste",
    action: #selector(NSText.paste(_:)),
    keyEquivalent: "v",
  )

  public static let pasteAndMatchStyle = NSMenuItem(
    "Paste and Match Style",
    action: #selector(NSTextView.pasteAsPlainText(_:)),
    keyEquivalent: "v",
  )
  .set(\.keyEquivalentModifierMask, to: [.option, .shift, .command])

  public static let delete = NSMenuItem(
    "Delete",
    action: #selector(NSText.delete(_:)),
  )

  public static let selectAll = NSMenuItem(
    "Select All",
    action: #selector(NSText.selectAll(_:)),
    keyEquivalent: "a",
  )

  public static let findMenu = NSMenuItem("Find") {
    find
    findAndReplace
    findNext
    findPrevious
    useSelectionForFind
    jumpToSelection
  }

  public static let find = NSMenuItem(
    "Find…",
    action: #selector(NSTextView.performFindPanelAction(_:)),
    keyEquivalent: "f",
  )
  .set(\.tag, to: NSTextFinder.Action.showFindInterface.rawValue)

  public static let findAndReplace = NSMenuItem(
    "Find and Replace…",
    action: #selector(NSTextView.performFindPanelAction(_:)),
    keyEquivalent: "f",
  )
  .set(\.keyEquivalentModifierMask, to: [.option, .command])
  .set(\.tag, to: NSTextFinder.Action.showReplaceInterface.rawValue)

  public static let findNext = NSMenuItem(
    "Find Next",
    action: #selector(NSTextView.performFindPanelAction(_:)),
    keyEquivalent: "g",
  )
  .set(\.tag, to: NSTextFinder.Action.nextMatch.rawValue)

  public static let findPrevious = NSMenuItem(
    "Find Previous",
    action: #selector(NSTextView.performFindPanelAction(_:)),
    keyEquivalent: "G",
  )
  .set(\.tag, to: NSTextFinder.Action.previousMatch.rawValue)

  public static let useSelectionForFind = NSMenuItem(
    "Use Selection for Find",
    action: #selector(NSTextView.performFindPanelAction(_:)),
    keyEquivalent: "e",
  )
  .set(\.tag, to: NSTextFinder.Action.setSearchString.rawValue)

  public static let jumpToSelection = NSMenuItem(
    "Jump to Selection",
    action: #selector(NSStandardKeyBindingResponding.centerSelectionInVisibleArea(_:)),
    keyEquivalent: "j",
  )

  public static let spellingAndGrammar = NSMenuItem("Spelling and Grammar") {
    showSpellingAndGrammar
    checkDocumentNow
    NSMenuItem.separator()
    checkSpellingWhileTyping
    checkGrammarWithSpelling
    correctSpellingAutomatically
  }

  public static let showSpellingAndGrammar = NSMenuItem(
    "Show Spelling and Grammar",
    action: #selector(NSText.showGuessPanel(_:)),
    keyEquivalent: ":",
  )

  public static let checkDocumentNow = NSMenuItem(
    "Check Document Now",
    action: #selector(NSText.checkSpelling(_:)),
    keyEquivalent: ";",
  )

  public static let checkSpellingWhileTyping = NSMenuItem(
    "Check Spelling While Typing",
    action: #selector(NSTextView.toggleContinuousSpellChecking(_:)),
  )

  public static let checkGrammarWithSpelling = NSMenuItem(
    "Check Grammar With Spelling",
    action: #selector(NSTextView.toggleGrammarChecking(_:)),
  )

  public static let correctSpellingAutomatically = NSMenuItem(
    "Correct Spelling Automatically",
    action: #selector(NSTextView.toggleAutomaticSpellingCorrection(_:)),
  )

  public static let substitutions = NSMenuItem("Substitutions") {
    showSubstitutions
    NSMenuItem.separator()
    smartCopyPaste
    smartQuotes
    smartDashes
    smartLinks
    dataDetectors
    textReplacement
  }

  public static let showSubstitutions = NSMenuItem(
    "Show Substitutions",
    action: #selector(NSTextView.orderFrontSubstitutionsPanel(_:)),
  )

  public static let smartCopyPaste = NSMenuItem(
    "Smart Copy/Paste",
    action: #selector(NSTextView.toggleSmartInsertDelete(_:)),
  )

  public static let smartQuotes = NSMenuItem(
    "Smart Quotes",
    action: #selector(NSTextView.toggleAutomaticQuoteSubstitution(_:)),
  )

  public static let smartDashes = NSMenuItem(
    "Smart Dashes",
    action: #selector(NSTextView.toggleAutomaticDashSubstitution(_:)),
  )

  public static let smartLinks = NSMenuItem(
    "Smart Links",
    action: #selector(NSTextView.toggleAutomaticLinkDetection(_:)),
  )

  public static let dataDetectors = NSMenuItem(
    "Data Detectors",
    action: #selector(NSTextView.toggleAutomaticDataDetection(_:)),
  )

  public static let textReplacement = NSMenuItem(
    "Text Replacement",
    action: #selector(NSTextView.toggleAutomaticTextReplacement(_:)),
  )

  public static let transformations = NSMenuItem("Transformations") {
    makeUpperCase
    makeLowerCase
    capitalize
  }

  public static let makeUpperCase = NSMenuItem(
    "Make Upper Case",
    action: #selector(NSResponder.uppercaseWord(_:)),
  )

  public static let makeLowerCase = NSMenuItem(
    "Make Lower Case",
    action: #selector(NSResponder.lowercaseWord(_:)),
  )

  public static let capitalize = NSMenuItem(
    "Capitalize",
    action: #selector(NSResponder.capitalizeWord(_:)),
  )

  public static let speech = NSMenuItem("Speech") {
    startSpeaking
    stopSpeaking
  }

  public static let startSpeaking = NSMenuItem(
    "Start Speaking",
    action: #selector(NSTextView.startSpeaking(_:)),
  )

  public static let stopSpeaking = NSMenuItem(
    "Stop Speaking",
    action: #selector(NSTextView.stopSpeaking(_:)),
  )

}

@MainActor
extension NSMenuItem {

  // MARK: - Format menu

  public static let formatMenu = NSMenuItem("Format") {
    fontMenu
    textMenu
  }

  public static let fontMenu = NSMenuItem("Font") {
    showFonts
    bold
    italic
    underline
    NSMenuItem.separator()
    bigger
    smaller
    NSMenuItem.separator()
    kernMenu
    ligaturesMenu
    baselineMenu
    NSMenuItem.separator()
    showColors
    NSMenuItem.separator()
    copyStyle
    pasteStyle
  }

  public static let showFonts = NSMenuItem(
    "Show Fonts",
    action: #selector(NSFontManager.orderFrontFontPanel(_:)),
    keyEquivalent: "t",
  )

  public static let bold = NSMenuItem(
    "Bold",
    action: #selector(NSFontManager.addFontTrait(_:)),
    keyEquivalent: "b",
  )
  .set(\.tag, to: Int(NSFontTraitMask.boldFontMask.rawValue))

  public static let italic = NSMenuItem(
    "Italic",
    action: #selector(NSFontManager.addFontTrait(_:)),
    keyEquivalent: "i",
  )
  .set(\.tag, to: Int(NSFontTraitMask.italicFontMask.rawValue))

  public static let underline = NSMenuItem(
    "Underline",
    action: #selector(NSText.underline(_:)),
    keyEquivalent: "u",
  )

  public static let bigger = NSMenuItem(
    "Bigger",
    action: #selector(NSFontManager.modifyFont(_:)),
    keyEquivalent: "+",
  )
  .set(\.tag, to: Int(NSFontAction.sizeUpFontAction.rawValue))

  public static let smaller = NSMenuItem(
    "Smaller",
    action: #selector(NSFontManager.modifyFont(_:)),
    keyEquivalent: "-",
  )
  .set(\.tag, to: Int(NSFontAction.sizeDownFontAction.rawValue))

  public static let kernMenu = NSMenuItem("Kern") {
    kernUseDefault
    kernUseNone
    kernTighten
    kernLoosen
  }

  public static let kernUseDefault = NSMenuItem(
    "Use Default",
    action: #selector(NSTextView.useStandardKerning(_:)),
  )

  public static let kernUseNone = NSMenuItem(
    "Use None",
    action: #selector(NSTextView.turnOffKerning(_:)),
  )

  public static let kernTighten = NSMenuItem(
    "Tighten",
    action: #selector(NSTextView.tightenKerning(_:)),
  )

  public static let kernLoosen = NSMenuItem(
    "Loosen",
    action: #selector(NSTextView.loosenKerning(_:)),
  )

  public static let ligaturesMenu = NSMenuItem("Ligatures") {
    ligaturesUseDefault
    ligaturesUseNone
    ligaturesUseAll
  }

  public static let ligaturesUseDefault = NSMenuItem(
    "Use Default",
    action: #selector(NSTextView.useStandardLigatures(_:)),
  )

  public static let ligaturesUseNone = NSMenuItem(
    "Use None",
    action: #selector(NSTextView.turnOffLigatures(_:)),
  )

  public static let ligaturesUseAll = NSMenuItem(
    "Use All",
    action: #selector(NSTextView.useAllLigatures(_:)),
  )

  public static let baselineMenu = NSMenuItem("Baseline") {
    baselineUseDefault
    baselineSuperscript
    baselineSubscript
    baselineRaise
    baselineLower
  }

  public static let baselineUseDefault = NSMenuItem(
    "Use Default",
    action: #selector(NSText.unscript(_:)),
  )

  public static let baselineSuperscript = NSMenuItem(
    "Superscript",
    action: #selector(NSText.superscript(_:)),
  )

  public static let baselineSubscript = NSMenuItem(
    "Subscript",
    action: #selector(NSText.subscript(_:)),
  )

  public static let baselineRaise = NSMenuItem(
    "Raise",
    action: #selector(NSTextView.raiseBaseline(_:)),
  )

  public static let baselineLower = NSMenuItem(
    "Lower",
    action: #selector(NSTextView.lowerBaseline(_:)),
  )

  public static let showColors = NSMenuItem(
    "Show Colors",
    action: #selector(NSApplication.orderFrontColorPanel(_:)),
    keyEquivalent: "C",
  )

  public static let copyStyle = NSMenuItem(
    "Copy Style",
    action: #selector(NSText.copyFont(_:)),
    keyEquivalent: "c",
  )
  .set(\.keyEquivalentModifierMask, to: [.option, .command])

  public static let pasteStyle = NSMenuItem(
    "Paste Style",
    action: #selector(NSText.pasteFont(_:)),
    keyEquivalent: "v",
  )
  .set(\.keyEquivalentModifierMask, to: [.option, .command])

  public static let textMenu = NSMenuItem("Text") {
    alignLeft
    center
    justify
    alignRight
    NSMenuItem.separator()
    writingDirectionMenu
    NSMenuItem.separator()
    showRuler
    copyRuler
    pasteRuler
  }

  public static let alignLeft = NSMenuItem(
    "Align Left",
    action: #selector(NSText.alignLeft(_:)),
    keyEquivalent: "{",
  )

  public static let center = NSMenuItem(
    "Center",
    action: #selector(NSText.alignCenter(_:)),
    keyEquivalent: "|",
  )

  public static let justify = NSMenuItem(
    "Justify",
    action: #selector(NSTextView.alignJustified(_:)),
  )

  public static let alignRight = NSMenuItem(
    "Align Right",
    action: #selector(NSText.alignRight(_:)),
    keyEquivalent: "}",
  )

  public static let writingDirectionMenu = NSMenuItem("Writing Direction") {
    paragraphLabel
    paragraphDefault
    paragraphLeftToRight
    paragraphRightToLeft
    NSMenuItem.separator()
    selectionLabel
    selectionDefault
    selectionLeftToRight
    selectionRightToLeft
  }

  public static let paragraphLabel = NSMenuItem("Paragraph")
    .set(\.isEnabled, to: false)

  public static let paragraphDefault = NSMenuItem(
    "\tDefault",
    action: #selector(NSResponder.makeBaseWritingDirectionNatural(_:)),
  )

  public static let paragraphLeftToRight = NSMenuItem(
    "\tLeft to Right",
    action: #selector(NSResponder.makeBaseWritingDirectionLeftToRight(_:)),
  )

  public static let paragraphRightToLeft = NSMenuItem(
    "\tRight to Left",
    action: #selector(NSResponder.makeBaseWritingDirectionRightToLeft(_:)),
  )

  public static let selectionLabel = NSMenuItem("Selection")
    .set(\.isEnabled, to: false)

  public static let selectionDefault = NSMenuItem(
    "\tDefault",
    action: #selector(NSResponder.makeTextWritingDirectionNatural(_:)),
  )

  public static let selectionLeftToRight = NSMenuItem(
    "\tLeft to Right",
    action: #selector(NSResponder.makeTextWritingDirectionLeftToRight(_:)),
  )

  public static let selectionRightToLeft = NSMenuItem(
    "\tRight to Left",
    action: #selector(NSResponder.makeTextWritingDirectionRightToLeft(_:)),
  )

  public static let showRuler = NSMenuItem(
    "Show Ruler",
    action: #selector(NSText.toggleRuler(_:)),
  )

  public static let copyRuler = NSMenuItem(
    "Copy Ruler",
    action: #selector(NSText.copyRuler(_:)),
    keyEquivalent: "c",
  )
  .set(\.keyEquivalentModifierMask, to: [.control, .command])

  public static let pasteRuler = NSMenuItem(
    "Paste Ruler",
    action: #selector(NSText.pasteRuler(_:)),
    keyEquivalent: "v",
  )
  .set(\.keyEquivalentModifierMask, to: [.control, .command])

}

@MainActor
extension NSMenuItem {

  // MARK: - View menu

  public static let viewMenu = NSMenuItem("View") {
    showToolbar
    customizeToolbar
    NSMenuItem.separator()
    showSidebar
    enterFullScreen
  }

  public static let showToolbar = NSMenuItem(
    "Show Toolbar",
    action: #selector(NSWindow.toggleToolbarShown(_:)),
    keyEquivalent: "t",
  )
  .set(\.keyEquivalentModifierMask, to: [.option, .command])

  public static let customizeToolbar = NSMenuItem(
    "Customize Toolbar…",
    action: #selector(NSWindow.runToolbarCustomizationPalette(_:)),
  )

  public static let showSidebar = NSMenuItem(
    "Show Sidebar",
    action: #selector(NSSplitViewController.toggleSidebar(_:)),
    keyEquivalent: "s",
  )
  .set(\.keyEquivalentModifierMask, to: [.control, .command])

  public static let enterFullScreen = NSMenuItem(
    "Enter Full Screen",
    action: #selector(NSWindow.toggleFullScreen(_:)),
    keyEquivalent: "f",
  )
  .set(\.keyEquivalentModifierMask, to: [.control, .command])

}

@MainActor
extension NSMenuItem {

  // MARK: - Window menu

  public static func windowMenu(app: NSApplication = .shared) -> NSMenuItem {
    let menuItem = NSMenuItem("Window") {
      minimize
      zoom
      NSMenuItem.separator()
      bringAllToFront
    }
    app.windowsMenu = menuItem.submenu
    return menuItem
  }

  public static let minimize = NSMenuItem(
    "Minimize",
    action: #selector(NSWindow.performMiniaturize(_:)),
    keyEquivalent: "m",
  )

  public static let zoom = NSMenuItem(
    "Zoom",
    action: #selector(NSWindow.performZoom(_:)),
  )

  public static let bringAllToFront = NSMenuItem(
    "Bring All to Front",
    action: #selector(NSApplication.arrangeInFront(_:)),
  )

}

@MainActor
extension NSMenuItem {

  // MARK: - Help menu

  public static func helpMenu(
    app: NSApplication = .shared,
    selector: Selector = #selector(NSApplication.showHelp(_:)),
    target: AnyObject? = NSApplication.shared,
  ) -> NSMenuItem {
    let menuItem = NSMenuItem("Help") {
      help(selector: selector, target: target)
    }
    app.helpMenu = menuItem.submenu
    return menuItem
  }

  public static func help(
    selector: Selector = #selector(NSApplication.showHelp(_:)),
    target: AnyObject? = NSApplication.shared,
  ) -> NSMenuItem {
    NSMenuItem(
      "\(String.appName) Help",
      selector: selector,
      target: target,
      keyEquivalent: "?",
    )
    .set(\.image, to: NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: nil))
  }

}
