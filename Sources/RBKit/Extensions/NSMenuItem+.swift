import AppKit

@MainActor
extension NSMenuItem {

  public convenience init(
    _ title: String,
    selector: Selector? = nil,
    target: AnyObject? = nil,
    keyEquivalent: String = "",
    @MenuBuilder builder: () -> [NSMenuItem] = { [] },
  ) {
    self.init(title: title, action: selector, keyEquivalent: keyEquivalent)
    self.target = target
    let children = builder()
    // Keep leaf menu items leafs; only create a submenu when children actually exist.
    if children.isEmpty { return }
    let menu = NSMenu(title: title)
    menu.items = children
    submenu = menu
  }

}

@MainActor
extension NSMenuItem {

  public static var about: NSMenuItem {
    NSMenuItem.about(target: NSApplication.shared)
  }

  public static var hide: NSMenuItem {
    NSMenuItem(
      "Hide \(String.appName)",
      selector: #selector(NSApplication.hide(_:)),
      keyEquivalent: "h",
    )
  }

  public static var hideOthers: NSMenuItem {
    NSMenuItem(
      "Hide Others",
      selector: #selector(NSApplication.hideOtherApplications(_:)),
      keyEquivalent: "h",
    )
    .set(\.keyEquivalentModifierMask, to: [.option, .command])
  }

  public static var showAll: NSMenuItem {
    NSMenuItem(
      "Show All",
      selector: #selector(NSApplication.unhideAllApplications(_:)),
    )
  }

  public static var quit: NSMenuItem {
    NSMenuItem(
      "Quit \(String.appName)",
      selector: #selector(NSApplication.terminate),
      keyEquivalent: "q",
    )
    .set(\.image, to: NSImage(systemSymbolName: "power", accessibilityDescription: nil))
  }

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

  public static func settings(
    action: Selector?,
    target: AnyObject?,
  ) -> NSMenuItem {
    let menuItem = NSMenuItem("Settings…", selector: action, keyEquivalent: ",")
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

  public static func about(
    selector: Selector = #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
    target: AnyObject? = NSApplication.shared,
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

  public static var fileMenu: NSMenuItem {
    NSMenuItem("File") {
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
  }

  public static var new: NSMenuItem {
    NSMenuItem(
      "New",
      selector: #selector(NSDocumentController.newDocument(_:)),
      keyEquivalent: "n",
    )
  }

  public static var open: NSMenuItem {
    NSMenuItem(
      "Open…",
      selector: #selector(NSDocumentController.openDocument(_:)),
      keyEquivalent: "o",
    )
  }

  public static var openRecent: NSMenuItem {
    NSMenuItem("Open Recent") {
      clearMenu
    }
  }

  public static var clearMenu: NSMenuItem {
    NSMenuItem(
      "Clear Menu",
      selector: #selector(NSDocumentController.clearRecentDocuments(_:)),
    )
  }

  public static var close: NSMenuItem {
    NSMenuItem(
      "Close",
      selector: #selector(NSWindow.performClose(_:)),
      keyEquivalent: "w",
    )
  }

  public static var save: NSMenuItem {
    NSMenuItem(
      "Save…",
      selector: #selector(NSDocument.save(_:)),
      keyEquivalent: "s",
    )
  }

  public static var saveAs: NSMenuItem {
    NSMenuItem(
      "Save As…",
      selector: #selector(NSDocument.saveAs(_:)),
      keyEquivalent: "S",
    )
  }

  public static var revertToSaved: NSMenuItem {
    NSMenuItem(
      "Revert to Saved",
      selector: #selector(NSDocument.revertToSaved(_:)),
      keyEquivalent: "r",
    )
  }

  public static var pageSetup: NSMenuItem {
    NSMenuItem(
      "Page Setup…",
      selector: #selector(NSDocument.runPageLayout(_:)),
      keyEquivalent: "P",
    )
  }

  public static var print: NSMenuItem {
    NSMenuItem(
      "Print…",
      selector: #selector(NSDocument.printDocument(_:)),
      keyEquivalent: "p",
    )
  }

}

@MainActor
extension NSMenuItem {

  public static var editMenu: NSMenuItem {
    NSMenuItem("Edit") {
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
  }

  public static var undo: NSMenuItem {
    NSMenuItem(
      "Undo",
      selector: #selector(UndoManager.undo),
      keyEquivalent: "z",
    )
  }

  public static var redo: NSMenuItem {
    NSMenuItem(
      "Redo",
      selector: #selector(UndoManager.redo),
      keyEquivalent: "Z",
    )
  }

  public static var cut: NSMenuItem {
    NSMenuItem(
      "Cut",
      selector: #selector(NSText.cut(_:)),
      keyEquivalent: "x",
    )
  }

  public static var copy: NSMenuItem {
    NSMenuItem(
      "Copy",
      selector: #selector(NSText.copy(_:)),
      keyEquivalent: "c",
    )
  }

  public static var paste: NSMenuItem {
    NSMenuItem(
      "Paste",
      selector: #selector(NSText.paste(_:)),
      keyEquivalent: "v",
    )
  }

  public static var pasteAndMatchStyle: NSMenuItem {
    NSMenuItem(
      "Paste and Match Style",
      selector: #selector(NSTextView.pasteAsPlainText(_:)),
      keyEquivalent: "v",
    )
    .set(\.keyEquivalentModifierMask, to: [.option, .shift, .command])
  }

  public static var delete: NSMenuItem {
    NSMenuItem(
      "Delete",
      selector: #selector(NSText.delete(_:)),
    )
  }

  public static var selectAll: NSMenuItem {
    NSMenuItem(
      "Select All",
      selector: #selector(NSText.selectAll(_:)),
      keyEquivalent: "a",
    )
  }

  public static var findMenu: NSMenuItem {
    NSMenuItem("Find") {
      find
      findAndReplace
      findNext
      findPrevious
      useSelectionForFind
      jumpToSelection
    }
  }

  public static var find: NSMenuItem {
    NSMenuItem(
      "Find…",
      selector: #selector(NSTextView.performFindPanelAction(_:)),
      keyEquivalent: "f",
    )
    .set(\.tag, to: NSTextFinder.Action.showFindInterface.rawValue)
  }

  public static var findAndReplace: NSMenuItem {
    NSMenuItem(
      "Find and Replace…",
      selector: #selector(NSTextView.performFindPanelAction(_:)),
      keyEquivalent: "f",
    )
    .set(\.keyEquivalentModifierMask, to: [.option, .command])
    .set(\.tag, to: NSTextFinder.Action.showReplaceInterface.rawValue)
  }

  public static var findNext: NSMenuItem {
    NSMenuItem(
      "Find Next",
      selector: #selector(NSTextView.performFindPanelAction(_:)),
      keyEquivalent: "g",
    )
    .set(\.tag, to: NSTextFinder.Action.nextMatch.rawValue)
  }

  public static var findPrevious: NSMenuItem {
    NSMenuItem(
      "Find Previous",
      selector: #selector(NSTextView.performFindPanelAction(_:)),
      keyEquivalent: "G",
    )
    .set(\.tag, to: NSTextFinder.Action.previousMatch.rawValue)
  }

  public static var useSelectionForFind: NSMenuItem {
    NSMenuItem(
      "Use Selection for Find",
      selector: #selector(NSTextView.performFindPanelAction(_:)),
      keyEquivalent: "e",
    )
    .set(\.tag, to: NSTextFinder.Action.setSearchString.rawValue)
  }

  public static var jumpToSelection: NSMenuItem {
    NSMenuItem(
      "Jump to Selection",
      selector: #selector(NSStandardKeyBindingResponding.centerSelectionInVisibleArea(_:)),
      keyEquivalent: "j",
    )
  }

  public static var spellingAndGrammar: NSMenuItem {
    NSMenuItem("Spelling and Grammar") {
      showSpellingAndGrammar
      checkDocumentNow
      NSMenuItem.separator()
      checkSpellingWhileTyping
      checkGrammarWithSpelling
      correctSpellingAutomatically
    }
  }

  public static var showSpellingAndGrammar: NSMenuItem {
    NSMenuItem(
      "Show Spelling and Grammar",
      selector: #selector(NSText.showGuessPanel(_:)),
      keyEquivalent: ":",
    )
  }

  public static var checkDocumentNow: NSMenuItem {
    NSMenuItem(
      "Check Document Now",
      selector: #selector(NSText.checkSpelling(_:)),
      keyEquivalent: ";",
    )
  }

  public static var checkSpellingWhileTyping: NSMenuItem {
    NSMenuItem(
      "Check Spelling While Typing",
      selector: #selector(NSTextView.toggleContinuousSpellChecking(_:)),
    )
  }

  public static var checkGrammarWithSpelling: NSMenuItem {
    NSMenuItem(
      "Check Grammar With Spelling",
      selector: #selector(NSTextView.toggleGrammarChecking(_:)),
    )
  }

  public static var correctSpellingAutomatically: NSMenuItem {
    NSMenuItem(
      "Correct Spelling Automatically",
      selector: #selector(NSTextView.toggleAutomaticSpellingCorrection(_:)),
    )
  }

  public static var substitutions: NSMenuItem {
    NSMenuItem("Substitutions") {
      showSubstitutions
      NSMenuItem.separator()
      smartCopyPaste
      smartQuotes
      smartDashes
      smartLinks
      dataDetectors
      textReplacement
    }
  }

  public static var showSubstitutions: NSMenuItem {
    NSMenuItem(
      "Show Substitutions",
      selector: #selector(NSTextView.orderFrontSubstitutionsPanel(_:)),
    )
  }

  public static var smartCopyPaste: NSMenuItem {
    NSMenuItem(
      "Smart Copy/Paste",
      selector: #selector(NSTextView.toggleSmartInsertDelete(_:)),
    )
  }

  public static var smartQuotes: NSMenuItem {
    NSMenuItem(
      "Smart Quotes",
      selector: #selector(NSTextView.toggleAutomaticQuoteSubstitution(_:)),
    )
  }

  public static var smartDashes: NSMenuItem {
    NSMenuItem(
      "Smart Dashes",
      selector: #selector(NSTextView.toggleAutomaticDashSubstitution(_:)),
    )
  }

  public static var smartLinks: NSMenuItem {
    NSMenuItem(
      "Smart Links",
      selector: #selector(NSTextView.toggleAutomaticLinkDetection(_:)),
    )
  }

  public static var dataDetectors: NSMenuItem {
    NSMenuItem(
      "Data Detectors",
      selector: #selector(NSTextView.toggleAutomaticDataDetection(_:)),
    )
  }

  public static var textReplacement: NSMenuItem {
    NSMenuItem(
      "Text Replacement",
      selector: #selector(NSTextView.toggleAutomaticTextReplacement(_:)),
    )
  }

  public static var transformations: NSMenuItem {
    NSMenuItem("Transformations") {
      makeUpperCase
      makeLowerCase
      capitalize
    }
  }

  public static var makeUpperCase: NSMenuItem {
    NSMenuItem(
      "Make Upper Case",
      selector: #selector(NSResponder.uppercaseWord(_:)),
    )
  }

  public static var makeLowerCase: NSMenuItem {
    NSMenuItem(
      "Make Lower Case",
      selector: #selector(NSResponder.lowercaseWord(_:)),
    )
  }

  public static var capitalize: NSMenuItem {
    NSMenuItem(
      "Capitalize",
      selector: #selector(NSResponder.capitalizeWord(_:)),
    )
  }

  public static var speech: NSMenuItem {
    NSMenuItem("Speech") {
      startSpeaking
      stopSpeaking
    }
  }

  public static var startSpeaking: NSMenuItem {
    NSMenuItem(
      "Start Speaking",
      selector: #selector(NSTextView.startSpeaking(_:)),
    )
  }

  public static var stopSpeaking: NSMenuItem {
    NSMenuItem(
      "Stop Speaking",
      selector: #selector(NSTextView.stopSpeaking(_:)),
    )
  }

}

@MainActor
extension NSMenuItem {

  public static var formatMenu: NSMenuItem {
    NSMenuItem("Format") {
      fontMenu
      textMenu
    }
  }

  public static var fontMenu: NSMenuItem {
    NSMenuItem("Font") {
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
  }

  public static var showFonts: NSMenuItem {
    NSMenuItem(
      "Show Fonts",
      selector: #selector(NSFontManager.orderFrontFontPanel(_:)),
      keyEquivalent: "t",
    )
  }

  public static var bold: NSMenuItem {
    NSMenuItem(
      "Bold",
      selector: #selector(NSFontManager.addFontTrait(_:)),
      keyEquivalent: "b",
    )
    .set(\.tag, to: Int(NSFontTraitMask.boldFontMask.rawValue))
  }

  public static var italic: NSMenuItem {
    NSMenuItem(
      "Italic",
      selector: #selector(NSFontManager.addFontTrait(_:)),
      keyEquivalent: "i",
    )
    .set(\.tag, to: Int(NSFontTraitMask.italicFontMask.rawValue))
  }

  public static var underline: NSMenuItem {
    NSMenuItem(
      "Underline",
      selector: #selector(NSText.underline(_:)),
      keyEquivalent: "u",
    )
  }

  public static var bigger: NSMenuItem {
    NSMenuItem(
      "Bigger",
      selector: #selector(NSFontManager.modifyFont(_:)),
      keyEquivalent: "+",
    )
    .set(\.tag, to: Int(NSFontAction.sizeUpFontAction.rawValue))
  }

  public static var smaller: NSMenuItem {
    NSMenuItem(
      "Smaller",
      selector: #selector(NSFontManager.modifyFont(_:)),
      keyEquivalent: "-",
    )
    .set(\.tag, to: Int(NSFontAction.sizeDownFontAction.rawValue))
  }

  public static var kernMenu: NSMenuItem {
    NSMenuItem("Kern") {
      kernUseDefault
      kernUseNone
      kernTighten
      kernLoosen
    }
  }

  public static var kernUseDefault: NSMenuItem {
    NSMenuItem(
      "Use Default",
      selector: #selector(NSTextView.useStandardKerning(_:)),
    )
  }

  public static var kernUseNone: NSMenuItem {
    NSMenuItem(
      "Use None",
      selector: #selector(NSTextView.turnOffKerning(_:)),
    )
  }

  public static var kernTighten: NSMenuItem {
    NSMenuItem(
      "Tighten",
      selector: #selector(NSTextView.tightenKerning(_:)),
    )
  }

  public static var kernLoosen: NSMenuItem {
    NSMenuItem(
      "Loosen",
      selector: #selector(NSTextView.loosenKerning(_:)),
    )
  }

  public static var ligaturesMenu: NSMenuItem {
    NSMenuItem("Ligatures") {
      ligaturesUseDefault
      ligaturesUseNone
      ligaturesUseAll
    }
  }

  public static var ligaturesUseDefault: NSMenuItem {
    NSMenuItem(
      "Use Default",
      selector: #selector(NSTextView.useStandardLigatures(_:)),
    )
  }

  public static var ligaturesUseNone: NSMenuItem {
    NSMenuItem(
      "Use None",
      selector: #selector(NSTextView.turnOffLigatures(_:)),
    )
  }

  public static var ligaturesUseAll: NSMenuItem {
    NSMenuItem(
      "Use All",
      selector: #selector(NSTextView.useAllLigatures(_:)),
    )
  }

  public static var baselineMenu: NSMenuItem {
    NSMenuItem("Baseline") {
      baselineUseDefault
      baselineSuperscript
      baselineSubscript
      baselineRaise
      baselineLower
    }
  }

  public static var baselineUseDefault: NSMenuItem {
    NSMenuItem(
      "Use Default",
      selector: #selector(NSText.unscript(_:)),
    )
  }

  public static var baselineSuperscript: NSMenuItem {
    NSMenuItem(
      "Superscript",
      selector: #selector(NSText.superscript(_:)),
    )
  }

  public static var baselineSubscript: NSMenuItem {
    NSMenuItem(
      "Subscript",
      selector: #selector(NSText.subscript(_:)),
    )
  }

  public static var baselineRaise: NSMenuItem {
    NSMenuItem(
      "Raise",
      selector: #selector(NSTextView.raiseBaseline(_:)),
    )
  }

  public static var baselineLower: NSMenuItem {
    NSMenuItem(
      "Lower",
      selector: #selector(NSTextView.lowerBaseline(_:)),
    )
  }

  public static var showColors: NSMenuItem {
    NSMenuItem(
      "Show Colors",
      selector: #selector(NSApplication.orderFrontColorPanel(_:)),
      keyEquivalent: "C",
    )
  }

  public static var copyStyle: NSMenuItem {
    NSMenuItem(
      "Copy Style",
      selector: #selector(NSText.copyFont(_:)),
      keyEquivalent: "c",
    )
    .set(\.keyEquivalentModifierMask, to: [.option, .command])
  }

  public static var pasteStyle: NSMenuItem {
    NSMenuItem(
      "Paste Style",
      selector: #selector(NSText.pasteFont(_:)),
      keyEquivalent: "v",
    )
    .set(\.keyEquivalentModifierMask, to: [.option, .command])
  }

  public static var textMenu: NSMenuItem {
    NSMenuItem("Text") {
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
  }

  public static var alignLeft: NSMenuItem {
    NSMenuItem(
      "Align Left",
      selector: #selector(NSText.alignLeft(_:)),
      keyEquivalent: "{",
    )
  }

  public static var center: NSMenuItem {
    NSMenuItem(
      "Center",
      selector: #selector(NSText.alignCenter(_:)),
      keyEquivalent: "|",
    )
  }

  public static var justify: NSMenuItem {
    NSMenuItem(
      "Justify",
      selector: #selector(NSTextView.alignJustified(_:)),
    )
  }

  public static var alignRight: NSMenuItem {
    NSMenuItem(
      "Align Right",
      selector: #selector(NSText.alignRight(_:)),
      keyEquivalent: "}",
    )
  }

  public static var writingDirectionMenu: NSMenuItem {
    NSMenuItem("Writing Direction") {
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
  }

  public static var paragraphLabel: NSMenuItem {
    NSMenuItem("Paragraph")
      .set(\.isEnabled, to: false)
  }

  public static var paragraphDefault: NSMenuItem {
    NSMenuItem(
      "\tDefault",
      selector: #selector(NSResponder.makeBaseWritingDirectionNatural(_:)),
    )
  }

  public static var paragraphLeftToRight: NSMenuItem {
    NSMenuItem(
      "\tLeft to Right",
      selector: #selector(NSResponder.makeBaseWritingDirectionLeftToRight(_:)),
    )
  }

  public static var paragraphRightToLeft: NSMenuItem {
    NSMenuItem(
      "\tRight to Left",
      selector: #selector(NSResponder.makeBaseWritingDirectionRightToLeft(_:)),
    )
  }

  public static var selectionLabel: NSMenuItem {
    NSMenuItem("Selection")
      .set(\.isEnabled, to: false)
  }

  public static var selectionDefault: NSMenuItem {
    NSMenuItem(
      "\tDefault",
      selector: #selector(NSResponder.makeTextWritingDirectionNatural(_:)),
    )
  }

  public static var selectionLeftToRight: NSMenuItem {
    NSMenuItem(
      "\tLeft to Right",
      selector: #selector(NSResponder.makeTextWritingDirectionLeftToRight(_:)),
    )
  }

  public static var selectionRightToLeft: NSMenuItem {
    NSMenuItem(
      "\tRight to Left",
      selector: #selector(NSResponder.makeTextWritingDirectionRightToLeft(_:)),
    )
  }

  public static var showRuler: NSMenuItem {
    NSMenuItem(
      "Show Ruler",
      selector: #selector(NSText.toggleRuler(_:)),
    )
  }

  public static var copyRuler: NSMenuItem {
    NSMenuItem(
      "Copy Ruler",
      selector: #selector(NSText.copyRuler(_:)),
      keyEquivalent: "c",
    )
    .set(\.keyEquivalentModifierMask, to: [.control, .command])
  }

  public static var pasteRuler: NSMenuItem {
    NSMenuItem(
      "Paste Ruler",
      selector: #selector(NSText.pasteRuler(_:)),
      keyEquivalent: "v",
    )
    .set(\.keyEquivalentModifierMask, to: [.control, .command])
  }

}

@MainActor
extension NSMenuItem {

  public static var viewMenu: NSMenuItem {
    NSMenuItem("View") {
      showToolbar
      customizeToolbar
      NSMenuItem.separator()
      showSidebar
      enterFullScreen
    }
  }

  public static var showToolbar: NSMenuItem {
    NSMenuItem(
      "Show Toolbar",
      selector: #selector(NSWindow.toggleToolbarShown(_:)),
      keyEquivalent: "t",
    )
    .set(\.keyEquivalentModifierMask, to: [.option, .command])
  }

  public static var customizeToolbar: NSMenuItem {
    NSMenuItem(
      "Customize Toolbar…",
      selector: #selector(NSWindow.runToolbarCustomizationPalette(_:)),
    )
  }

  public static var showSidebar: NSMenuItem {
    NSMenuItem(
      "Show Sidebar",
      selector: #selector(NSSplitViewController.toggleSidebar(_:)),
      keyEquivalent: "s",
    )
    .set(\.keyEquivalentModifierMask, to: [.control, .command])
  }

  public static var enterFullScreen: NSMenuItem {
    NSMenuItem(
      "Enter Full Screen",
      selector: #selector(NSWindow.toggleFullScreen(_:)),
      keyEquivalent: "f",
    )
    .set(\.keyEquivalentModifierMask, to: [.control, .command])
  }

}

@MainActor
extension NSMenuItem {

  public static var minimize: NSMenuItem {
    NSMenuItem(
      "Minimize",
      selector: #selector(NSWindow.performMiniaturize(_:)),
      keyEquivalent: "m",
    )
  }

  public static var zoom: NSMenuItem {
    NSMenuItem(
      "Zoom",
      selector: #selector(NSWindow.performZoom(_:)),
    )
  }

  public static var bringAllToFront: NSMenuItem {
    NSMenuItem(
      "Bring All to Front",
      selector: #selector(NSApplication.arrangeInFront(_:)),
    )
  }

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

}

@MainActor
extension NSMenuItem {

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
