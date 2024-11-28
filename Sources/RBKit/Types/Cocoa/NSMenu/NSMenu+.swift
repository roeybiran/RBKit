import AppKit

extension NSMenu {

  public convenience init(_ title: String, @MenuBuilder builder: () -> [NSMenuItem] = { [] }) {
    self.init(title: title)
    items = builder()
  }
}

extension NSMenu {

  // MARK: Public

  @MainActor public static func fromNib(named nibName: String, bundle: Bundle = .main) -> NSMenu {
    let nib = NSNib(nibNamed: nibName, bundle: bundle)
    var objects: NSArray?
    nib?.instantiate(withOwner: NSApplication.shared.delegate, topLevelObjects: &objects)
    let menu = ((objects as? [Any])?.first(where: { $0 is NSMenu }) as? NSMenu) ?? .init()
    return menu
  }

  // MARK: Internal

  /// A programmatically created application menu bar (`NSApp.mainMenu`). The menu’s structure and contents are an exact clone of those in a Storyboard–based, non–modified menu bar (as of **Xcode 14.2**). This is not meant to be used directly in your project (hence the lack of the `public` modifier), but rather copied and modified to suit your needs.
  @MainActor static let standardMenuBar = NSMenu(APP_NAME) {
    NSMenuItem(APP_NAME) {
      NSMenuItem(
        "About \(APP_NAME)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)))
      NSMenuItem.separator()
      NSMenuItem.settingsMenuItem()
      NSMenuItem.separator()
      NSMenuItem.servicesMenu()
      NSMenuItem.separator()
      NSMenuItem("Hide \(APP_NAME)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
      NSMenuItem(
        "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)),
        keyEquivalent: "h"
      )
      .set(\.keyEquivalentModifierMask, to: [.option, .command])
      NSMenuItem("Show All", action: #selector(NSApplication.unhideAllApplications(_:)))
      NSMenuItem.separator()
      NSMenuItem("Quit \(APP_NAME)", action: #selector(NSApplication.terminate), keyEquivalent: "q")
    }
    NSMenuItem("File") {
      NSMenuItem("New", action: #selector(NSDocumentController.newDocument(_:)), keyEquivalent: "n")
      NSMenuItem(
        "Open…", action: #selector(NSDocumentController.openDocument(_:)), keyEquivalent: "o")
      NSMenuItem("Open Recent") {
        NSMenuItem("Clear Menu", action: #selector(NSDocumentController.clearRecentDocuments(_:)))
      }
      NSMenuItem.separator()
      NSMenuItem("Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
      NSMenuItem("Save", action: #selector(NSDocument.save(_:)), keyEquivalent: "s")
      NSMenuItem("Save As…", action: #selector(NSDocument.saveAs(_:)), keyEquivalent: "S")
      NSMenuItem(
        "Revert to Saved", action: #selector(NSDocument.revertToSaved(_:)), keyEquivalent: "R")
      NSMenuItem.separator()
      NSMenuItem("Page Setup…", action: #selector(NSDocument.runPageLayout(_:)), keyEquivalent: "P")
      NSMenuItem("Print…", action: #selector(NSDocument.printDocument(_:)), keyEquivalent: "p")
    }
    NSMenuItem("Edit") {
      NSMenuItem("Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
      NSMenuItem("Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z")
      NSMenuItem.separator()
      NSMenuItem("Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
      NSMenuItem("Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
      NSMenuItem("Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
      NSMenuItem(
        "Paste and Match Style", action: #selector(NSTextView.pasteAsPlainText(_:)),
        keyEquivalent: "v"
      )
      .set(\.keyEquivalentModifierMask, to: [.option, .shift, .command])
      NSMenuItem("Delete", action: #selector(NSText.delete(_:)))
      NSMenuItem("Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
      NSMenuItem.separator()
      NSMenuItem("Find") {
        NSMenuItem(
          "Find…", action: #selector(NSResponder.performTextFinderAction(_:)), keyEquivalent: "f"
        )
        .set(\.tag, to: NSTextFinder.Action.showFindInterface.rawValue)
        NSMenuItem(
          "Find and Replace…", action: #selector(NSResponder.performTextFinderAction(_:)),
          keyEquivalent: "f"
        )
        .set(\.keyEquivalentModifierMask, to: [.option, .command])
        .set(\.tag, to: NSTextFinder.Action.showReplaceInterface.rawValue)
        NSMenuItem(
          "Find Next", action: #selector(NSResponder.performTextFinderAction(_:)),
          keyEquivalent: "g"
        )
        .set(\.tag, to: NSTextFinder.Action.nextMatch.rawValue)
        NSMenuItem(
          "Find Previous", action: #selector(NSResponder.performTextFinderAction(_:)),
          keyEquivalent: "G"
        )
        .set(\.tag, to: NSTextFinder.Action.previousMatch.rawValue)
        NSMenuItem(
          "Use Selection for Find",
          action: #selector(NSResponder.performTextFinderAction(_:)),
          keyEquivalent: "e"
        )
        .set(\.tag, to: NSTextFinder.Action.setSearchString.rawValue)
        NSMenuItem(
          "Jump to Selection",
          action: #selector(NSStandardKeyBindingResponding.centerSelectionInVisibleArea(_:)),
          keyEquivalent: "j")
      }
      NSMenuItem("Spelling and Grammar") {
        NSMenuItem(
          "Show Spelling and Grammar", action: #selector(NSText.showGuessPanel(_:)),
          keyEquivalent: ":")
        NSMenuItem(
          "Check Document Now", action: #selector(NSText.checkSpelling(_:)), keyEquivalent: ";")
        NSMenuItem.separator()
        NSMenuItem(
          "Check Spelling While Typing",
          action: #selector(NSTextView.toggleContinuousSpellChecking(_:)))
        NSMenuItem(
          "Check Grammar With Spelling", action: #selector(NSTextView.toggleGrammarChecking(_:)))
        NSMenuItem(
          "Correct Spelling Automatically",
          action: #selector(NSTextView.toggleAutomaticSpellingCorrection(_:)))
      }
      NSMenuItem("Substitutions") {
        NSMenuItem(
          "Show Substitutions", action: #selector(NSTextView.orderFrontSubstitutionsPanel(_:)))
        NSMenuItem.separator()
        NSMenuItem("Smart Copy/Paste", action: #selector(NSTextView.toggleSmartInsertDelete(_:)))
        NSMenuItem(
          "Smart Quotes", action: #selector(NSTextView.toggleAutomaticQuoteSubstitution(_:)))
        NSMenuItem(
          "Smart Dashes", action: #selector(NSTextView.toggleAutomaticDashSubstitution(_:)))
        NSMenuItem("Smart Links", action: #selector(NSTextView.toggleAutomaticLinkDetection(_:)))
        NSMenuItem("Data Detectors", action: #selector(NSTextView.toggleAutomaticDataDetection(_:)))
        NSMenuItem(
          "Text Replacement", action: #selector(NSTextView.toggleAutomaticTextReplacement(_:)))
      }
      NSMenuItem("Transformations") {
        NSMenuItem("Make Upper Case", action: #selector(NSResponder.uppercaseWord(_:)))
        NSMenuItem("Make Lower Case", action: #selector(NSResponder.lowercaseWord(_:)))
        NSMenuItem("Capitalize", action: #selector(NSResponder.capitalizeWord(_:)))
      }
      NSMenuItem("Speech") {
        NSMenuItem("Start Speaking", action: #selector(NSTextView.startSpeaking(_:)))
        NSMenuItem("Stop Speaking", action: #selector(NSTextView.stopSpeaking(_:)))
      }
    }
    NSMenuItem("Format") {
      NSMenuItem("Font") {
        NSMenuItem(
          "Show Fonts", action: #selector(NSFontManager.orderFrontFontPanel(_:)), keyEquivalent: "t"
        )
        NSMenuItem("Bold", action: #selector(NSFontManager.addFontTrait(_:)), keyEquivalent: "b")
          .set(\.tag, to: 2)
        NSMenuItem("Italic", action: #selector(NSFontManager.addFontTrait(_:)), keyEquivalent: "i")
          .set(\.tag, to: 1)
        NSMenuItem("Underline", action: #selector(NSText.underline(_:)), keyEquivalent: "u")
        NSMenuItem.separator()
        NSMenuItem("Bigger", action: #selector(NSFontManager.modifyFont(_:)), keyEquivalent: "+")
          .set(\.tag, to: 3)
        NSMenuItem("Smaller", action: #selector(NSFontManager.modifyFont(_:)), keyEquivalent: "-")
          .set(\.tag, to: 4)
        NSMenuItem.separator()
        NSMenuItem("Kern") {
          NSMenuItem("Use Default", action: #selector(NSTextView.useStandardKerning(_:)))
          NSMenuItem("Use None", action: #selector(NSTextView.turnOffKerning(_:)))
          NSMenuItem("Tighten", action: #selector(NSTextView.tightenKerning(_:)))
          NSMenuItem("Loosen", action: #selector(NSTextView.loosenKerning(_:)))
        }
        NSMenuItem("Ligatures") {
          NSMenuItem("Use Default", action: #selector(NSTextView.useStandardLigatures(_:)))
          NSMenuItem("Use None", action: #selector(NSTextView.turnOffLigatures(_:)))
          NSMenuItem("Use All", action: #selector(NSTextView.useAllLigatures(_:)))
        }
        NSMenuItem("Baseline") {
          NSMenuItem("Use Default", action: #selector(NSText.unscript(_:)))
          NSMenuItem("Superscript", action: #selector(NSText.superscript(_:)))
          NSMenuItem("Subscript", action: #selector(NSText.subscript(_:)))
          NSMenuItem("Raise", action: #selector(NSTextView.raiseBaseline(_:)))
          NSMenuItem("Lower", action: #selector(NSTextView.lowerBaseline(_:)))
        }
        NSMenuItem.separator()
        NSMenuItem(
          "Show Colors", action: #selector(NSApplication.orderFrontColorPanel(_:)),
          keyEquivalent: "C")
        NSMenuItem.separator()
        NSMenuItem("Copy Style", action: #selector(NSText.copyFont(_:)), keyEquivalent: "c")
          .set(\.keyEquivalentModifierMask, to: [.option, .command])
        NSMenuItem("Paste Style", action: #selector(NSText.pasteFont(_:)), keyEquivalent: "v")
          .set(\.keyEquivalentModifierMask, to: [.option, .command])
      }
      NSMenuItem("Text") {
        NSMenuItem("Align Left", action: #selector(NSText.alignLeft(_:)), keyEquivalent: "{")
        NSMenuItem("Center", action: #selector(NSText.alignCenter(_:)), keyEquivalent: "|")
        NSMenuItem("Justify", action: #selector(NSTextView.alignJustified(_:)))
        NSMenuItem("Align Right", action: #selector(NSText.alignRight(_:)), keyEquivalent: "}")
        NSMenuItem.separator()
        NSMenuItem("Writing Direction", action: #selector(NSText.unscript(_:))) {
          NSMenuItem("Paragraph")
            .set(\.isEnabled, to: false)
          NSMenuItem(
            "\tDefault", action: #selector(NSResponder.makeBaseWritingDirectionNatural(_:)))
          NSMenuItem(
            "\tLeft to Right",
            action: #selector(NSResponder.makeBaseWritingDirectionLeftToRight(_:)))
          NSMenuItem(
            "\tRight to Left",
            action: #selector(NSResponder.makeBaseWritingDirectionRightToLeft(_:)))
          NSMenuItem.separator()
          NSMenuItem("Selection")
            .set(\.isEnabled, to: false)
          NSMenuItem(
            "\tDefault", action: #selector(NSResponder.makeTextWritingDirectionNatural(_:)))
          NSMenuItem(
            "\tLeft to Right",
            action: #selector(NSResponder.makeTextWritingDirectionLeftToRight(_:)))
          NSMenuItem(
            "\tRight to Left",
            action: #selector(NSResponder.makeTextWritingDirectionRightToLeft(_:)))
        }
        NSMenuItem.separator()
        NSMenuItem("Show Ruler", action: #selector(NSText.toggleRuler(_:)))
        NSMenuItem("Copy Ruler", action: #selector(NSText.copyRuler(_:)), keyEquivalent: "c")
          .set(\.keyEquivalentModifierMask, to: [.control, .command])
        NSMenuItem("Paste Ruler", action: #selector(NSText.pasteRuler(_:)), keyEquivalent: "v")
          .set(\.keyEquivalentModifierMask, to: [.control, .command])
      }
    }
    NSMenuItem("View") {
      NSMenuItem(
        "Show Toolbar", action: #selector(NSWindow.toggleToolbarShown(_:)), keyEquivalent: "t"
      )
      .set(\.keyEquivalentModifierMask, to: [.option, .command])
      NSMenuItem(
        "Customize Toolbar…", action: #selector(NSWindow.runToolbarCustomizationPalette(_:)))
      NSMenuItem.separator()
      NSMenuItem(
        "Show Sidebar", action: #selector(NSSplitViewController.toggleSidebar(_:)),
        keyEquivalent: "s"
      )
      .set(\.keyEquivalentModifierMask, to: [.control, .command])
      NSMenuItem(
        "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f"
      )
      .set(\.keyEquivalentModifierMask, to: [.control, .command])
    }
    NSMenuItem.windowMenu {
      NSMenuItem("Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
      NSMenuItem("Zoom", action: #selector(NSWindow.performZoom(_:)))
      NSMenuItem.separator()
      NSMenuItem("Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)))
    }
    NSMenuItem.helpMenu {
      NSMenuItem(
        "\(APP_NAME) Help", action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "?")
    }
  }

  // MARK: Private

  private static let APP_NAME = "YOUR_APP_NAME"

}
