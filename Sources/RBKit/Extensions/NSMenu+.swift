import AppKit

extension NSMenu {

  // MARK: Lifecycle

  public convenience init(
    _ title: String,
    @MenuBuilder builder: () -> [NSMenuItem] = {
      []
    }
  ) {
    self.init(
      title: title
    )
    items = builder()
  }
  
  // MARK: Public
  
  @MainActor
  public static func fromNib(
    named nibName: String,
    bundle: Bundle = .main
  ) -> NSMenu {
    let nib = NSNib(
      nibNamed: nibName,
      bundle: bundle
    )
    var objects: NSArray?
    nib?
      .instantiate(
        withOwner: NSApplication.shared.delegate,
        topLevelObjects: &objects
      )
    return (
      (
        objects as? [Any]
      )?.first(
        where: {
          $0 is NSMenu
        }) as? NSMenu
    ) ?? .init()
  }
  
  // MARK: Internal
  
  /// A programmatically created application menu bar (`NSApp.mainMenu`). The menu’s structure and contents are an exact clone of those in a Storyboard–based, non–modified menu bar (as of **Xcode 14.2**). This is not meant to be used directly in your project (hence the lack of the `public` modifier), but rather copied and modified to suit your needs.
  @MainActor static let standardMenuBar: NSMenu = {
    return NSMenu(
      NSMenuItem.appName
    ) {
      NSMenuItem.application
        .withChildren {
          NSMenuItem.about
          NSMenuItem
            .separator()
          NSMenuItem.settings
          NSMenuItem
            .separator()
          NSMenuItem
            .servicesMenu()
          NSMenuItem
            .separator()
          NSMenuItem.hide
          NSMenuItem.hideOthers
          NSMenuItem.showAll
          NSMenuItem
            .separator()
          NSMenuItem.quit
        }
      NSMenuItem.file
        .withChildren {
          NSMenuItem.new
          NSMenuItem.open
          NSMenuItem.openRecent
            .withChildren {
              NSMenuItem.clearMenu
            }
          NSMenuItem
            .separator()
          NSMenuItem.close
          NSMenuItem.save
          NSMenuItem.saveAs
          NSMenuItem.revertToSaved
          NSMenuItem
            .separator()
          NSMenuItem.pageSetup
          NSMenuItem.print
        }
      NSMenuItem.edit
        .withChildren {
          NSMenuItem.undo
          NSMenuItem.redo
          NSMenuItem
            .separator()
          NSMenuItem.cut
          NSMenuItem.copy
          NSMenuItem.paste
          NSMenuItem.pasteAndMatchStyle
          NSMenuItem.delete
          NSMenuItem.selectAll
          NSMenuItem
            .separator()
          NSMenuItem.findMenu
            .withChildren {
              NSMenuItem.find
              NSMenuItem.findAndReplace
              NSMenuItem.findNext
              NSMenuItem.findPrevious
              NSMenuItem.useSelectionForFind
              NSMenuItem.jumpToSelection
            }
          NSMenuItem.spellingAndGrammar
            .withChildren {
              NSMenuItem.showSpellingAndGrammar
              NSMenuItem.checkDocumentNow
              NSMenuItem
                .separator()
              NSMenuItem.checkSpellingWhileTyping
              NSMenuItem.checkGrammarWithSpelling
              NSMenuItem.correctSpellingAutomatically
            }
          NSMenuItem.substitutions
            .withChildren {
              NSMenuItem.showSubstitutions
              NSMenuItem
                .separator()
              NSMenuItem.smartCopyPaste
              NSMenuItem.smartQuotes
              NSMenuItem.smartDashes
              NSMenuItem.smartLinks
              NSMenuItem.dataDetectors
              NSMenuItem.textReplacement
            }
          NSMenuItem.transformations
            .withChildren {
              NSMenuItem.makeUpperCase
              NSMenuItem.makeLowerCase
              NSMenuItem.capitalize
            }
          NSMenuItem.speech
            .withChildren {
              NSMenuItem.startSpeaking
              NSMenuItem.stopSpeaking
            }
        }
      NSMenuItem.format
        .withChildren {
          NSMenuItem.fontMenu
            .withChildren {
              NSMenuItem.showFonts
              NSMenuItem.bold
              NSMenuItem.italic
              NSMenuItem.underline
              NSMenuItem
                .separator()
              NSMenuItem.bigger
              NSMenuItem.smaller
              NSMenuItem
                .separator()
              NSMenuItem.kernMenu
                .withChildren {
                  NSMenuItem.kernUseDefault
                  NSMenuItem.kernUseNone
                  NSMenuItem.kernTighten
                  NSMenuItem.kernLoosen
                }
              NSMenuItem.ligaturesMenu
                .withChildren {
                  NSMenuItem.ligaturesUseDefault
                  NSMenuItem.ligaturesUseNone
                  NSMenuItem.ligaturesUseAll
                }
              NSMenuItem.baselineMenu
                .withChildren {
                  NSMenuItem.baselineUseDefault
                  NSMenuItem.baselineSuperscript
                  NSMenuItem.baselineSubscript
                  NSMenuItem.baselineRaise
                  NSMenuItem.baselineLower
                }
              NSMenuItem
                .separator()
              NSMenuItem.showColors
              NSMenuItem
                .separator()
              NSMenuItem.copyStyle
              NSMenuItem.pasteStyle
            }
          NSMenuItem.textMenu
            .withChildren {
              NSMenuItem.alignLeft
              NSMenuItem.center
              NSMenuItem.justify
              NSMenuItem.alignRight
              NSMenuItem
                .separator()
              NSMenuItem.writingDirectionMenu
                .withChildren {
                  NSMenuItem.paragraphLabel
                  NSMenuItem.paragraphDefault
                  NSMenuItem.paragraphLeftToRight
                  NSMenuItem.paragraphRightToLeft
                  NSMenuItem
                    .separator()
                  NSMenuItem.selectionLabel
                  NSMenuItem.selectionDefault
                  NSMenuItem.selectionLeftToRight
                  NSMenuItem.selectionRightToLeft
                }
              NSMenuItem
                .separator()
              NSMenuItem.showRuler
              NSMenuItem.copyRuler
              NSMenuItem.pasteRuler
            }
        }
      NSMenuItem.view
        .withChildren {
          NSMenuItem.showToolbar
          NSMenuItem.customizeToolbar
          NSMenuItem
            .separator()
          NSMenuItem.showSidebar
          NSMenuItem.enterFullScreen
        }
      NSMenuItem
        .windowMenu()
        .withChildren {
          NSMenuItem.minimize
          NSMenuItem.zoom
          NSMenuItem
            .separator()
          NSMenuItem.bringAllToFront
        }
      NSMenuItem
        .helpMenu()
        .withChildren {
          NSMenuItem.appHelp
        }
    }
  }()
}
