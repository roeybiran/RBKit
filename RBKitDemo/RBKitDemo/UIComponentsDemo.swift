import Cocoa
import Dependencies
import RBKit
import SwiftUI

// MARK: - UIComponentsDemoViewController

final class UIComponentsDemoViewController: NSViewController {

  let operationButton = OperationButton(idleTitle: "Submit")
  let shimmerTextField = ShimmerTextField(labelWithString: "Getting Menu Items…")
  let confettiView = ConfettiView()

  var notificationView: ToastView?

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  lazy var menubarExtraCheckbox = MenuBarExtraSettingView(statusItem: statusItem)

  lazy var settingsWindowController = SettingsWindowController([
    Pane(
      "General",
      identifier: "general",
      systemImage: "gearshape.fill",
      viewController: GeneralPane(),
    ),
    Pane(
      "Appearance",
      identifier: "appearance",
      systemImage: "paintpalette.fill",
      viewController: AppearancePane(),
    ),
    Pane(
      "Advanced",
      identifier: "advanced",
      systemImage: "wrench.and.screwdriver.fill",
      viewController: AdvancedPane(),
    ),
  ])

  var operationButtonOperationCount = 0

  override func loadView() {
    view = NSView(frame: .init(x: 0, y: 0, width: 600, height: 700))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    operationButton.controlSize = .large
    operationButton.target = self
    operationButton.action = #selector(startOperation)

    statusItem.button?.image = .init(
      systemSymbolName: "gearshape.fill",
      accessibilityDescription: nil,
    )

    let menu = NSMenu("Main")
    menu.items = [
      NSMenuItem(
        title: "Quit \(String.appName)",
        action: #selector(NSApplication.terminate),
        keyEquivalent: "q",
      )
    ]
    statusItem.menu = menu

    let imageView = BorderedImageView(frame: .init(x: 0, y: 0, width: 48, height: 48))
    imageView.borderWidth = 3
    imageView.borerColor = .controlAccentColor
    imageView.image = NSImage(named: NSImage.applicationIconName)
    imageView.imageScaling = .scaleProportionallyDown

    let betaLabel = RBLabel()
    betaLabel.stringValue = "Beta"
    betaLabel.contentColor = .systemBlue

    let activeLabel = RBLabel()
    activeLabel.stringValue = "Active"
    activeLabel.contentColor = .systemGreen
    activeLabel.isSelected = true

    let featuredLabel = RBLabel()
    featuredLabel.stringValue = "Featured"
    featuredLabel.contentColor = .systemOrange
    featuredLabel.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
    featuredLabel.isBordered = true

    let labelStack = NSStackView(views: [betaLabel, activeLabel, featuredLabel])
    labelStack.orientation = .horizontal
    labelStack.alignment = .centerY
    labelStack.spacing = 8

    let showToastItem = NSMenuItem(
      title: "Show Toast",
      action: #selector(notify),
      keyEquivalent: "",
    )
    showToastItem.target = self
    let confettiItem = NSMenuItem(
      title: "Shoot Confetti",
      action: #selector(emitConfetti),
      keyEquivalent: "",
    )
    confettiItem.target = self
    let shimmerItem = NSMenuItem(title: "Shimmer", action: #selector(shimmer), keyEquivalent: "")
    shimmerItem.target = self
    let crashItem = NSMenuItem(title: "Crash", action: #selector(crash), keyEquivalent: "")
    crashItem.target = self
    let crashReporterItem = NSMenuItem(
      title: "Show Crash Reporter",
      action: #selector(showCrashReporter),
      keyEquivalent: "",
    )
    crashReporterItem.target = self
    let showSettingsItem = NSMenuItem(
      title: "Show Settings Window",
      action: #selector(showSettings),
      keyEquivalent: "",
    )
    showSettingsItem.target = self
    let toggleFloatsItem = NSMenuItem.ToggleSettingsWindowFloats()
    let demoActionsButton = NSPopUpButton(frame: .zero, pullsDown: true)
    let demoActionsMenu = NSMenu("Actions")
    let actionsTitleItem = NSMenuItem(title: "Actions", action: nil, keyEquivalent: "")
    actionsTitleItem.isEnabled = false
    demoActionsMenu.items = [
      actionsTitleItem,
      .separator(),
      showToastItem,
      confettiItem,
      shimmerItem,
      crashItem,
      crashReporterItem,
      showSettingsItem,
      toggleFloatsItem,
    ]
    demoActionsButton.menu = demoActionsMenu

    func Header(_ text: String) -> NSTextField {
      let field = NSTextField(labelWithString: text)
      field.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
      return field
    }

    let mainStack = NSStackView(views: [
      Header("Actions"),
      demoActionsButton,
      NSBox.separator(),
      Header("Shimmer Text Field"),
      shimmerTextField,
      NSBox.separator(),
      Header("Operation Button"),
      operationButton,
      NSBox.separator(),
      Header("Bordered Image View"),
      imageView,
      NSBox.separator(),
      Header("Menu Bar Extra View"),
      NSHostingView(rootView: menubarExtraCheckbox),
      NSBox.separator(),
      Header("Labels"),
      labelStack,
      NSBox.separator(),
      Header("Input Source Picker"),
      NSHostingView(rootView: InputSourcePickerView()),
    ])
    mainStack.orientation = .vertical
    mainStack.alignment = .leading
    mainStack.edgeInsets = .init(20)

    confettiView.translatesAutoresizingMaskIntoConstraints = false

    let scrollView = NSScrollView(frame: .zero)
    scrollView.drawsBackground = false
    scrollView.documentView = mainStack
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.borderType = .lineBorder

    view.addSubview(confettiView)
    view.addSubview(scrollView)

    NSLayoutConstraint.activate {
      scrollView.constraints(for: .pinningToEdges, of: view, offset: .uniform(20))
      confettiView.constraints(for: .pinningToEdges, of: view)
    }
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    view.window?.center()
  }

  @objc
  func startOperation(_: Any) {
    operationButton.status = .init(.busy, title: "Awaiting Approval…")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      guard let self else { return }
      if operationButtonOperationCount % 2 == 0 {
        operationButton.status = .init(.error, title: "Denied")
      } else if operationButtonOperationCount % 3 == 0 {
        operationButton.status = nil
      } else {
        operationButton.status = nil
      }
    }
    operationButtonOperationCount += 1
  }

  @objc
  func notify(_: Any) {
    notificationView?.dismiss(nil)
    notificationView = ToastView()
    notificationView?.textField.stringValue = "Operation Completed Successfully"
    notificationView?.maxWidth = 400
    notificationView?.notificationLifetime = 10
    notificationView?.show(in: view)
  }

  @objc
  func emitConfetti(_: Any) {
    confettiView.emit(for: 2)
  }

  @objc
  func shimmer(_: Any) {
    view.startShimmering()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.view.stopShimmering()
    }
  }

  @objc
  func crash(_: Any) {
    fatalError("foo")
  }

  @objc
  func showCrashReporter(_: Any) {
    withDependencies {
      $0.crashReporterClient.mostRecent = {
        CrashReport(
          url: URL(fileURLWithPath: "/tmp/Example.ips"),
          date: .now,
          contents: "Example crash report contents.",
        )
      }
    } operation: {
      CrashReporterWindow.showModalIfNeeded(email: "support@example.com")
    }
  }

  @objc
  func showSettings(_: Any) {
    settingsWindowController.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
}

// MARK: - GeneralPane

final class GeneralPane: NSViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let content = NSTextView()
    content.string =
      "General settings content goes here.\n\nThis pane demonstrates a larger content area with scrollable text."
    view.addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate {
      content.constraints(for: .pinningToEdges, of: view, offset: .uniform(20))
      content.widthAnchor.constraint(equalToConstant: 410)
      content.heightAnchor.constraint(equalToConstant: 300)
    }
  }
}

// MARK: - AppearancePane

final class AppearancePane: NSViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let stack = NSStackView(views: [
      NSTextField(labelWithString: "Appearance Settings"),
      NSTextField(labelWithString: "Theme options and visual customizations would go here."),
    ])
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 12

    view.addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate {
      stack.constraints(for: .pinningToEdges, of: view, offset: .uniform(20))
    }
  }
}

// MARK: - AdvancedPane

final class AdvancedPane: NSViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let resetButton = NSButton(title: "Reset All Settings", target: nil, action: nil)
    let exportButton = NSButton(title: "Export Configuration", target: nil, action: nil)

    let stack = NSStackView(views: [
      NSTextField(labelWithString: "Advanced Settings"),
      resetButton,
      exportButton,
    ])
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 12

    view.addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate {
      stack.constraints(for: .pinningToEdges, of: view, offset: .uniform(20))
    }
  }
}

// MARK: - UIComponentsDemo

struct UIComponentsDemo: NSViewControllerRepresentable {
  func makeNSViewController(context _: Context) -> UIComponentsDemoViewController {
    UIComponentsDemoViewController()
  }

  func updateNSViewController(_: UIComponentsDemoViewController, context _: Context) { }
}
