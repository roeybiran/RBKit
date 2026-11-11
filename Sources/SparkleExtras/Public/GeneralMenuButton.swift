import AppKit
import Foundation
import Sparkle

public final class GeneralMenuButton: NSPopUpButton {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero, pullsDown: true)

    updateAvailableOverlayDot.translatesAutoresizingMaskIntoConstraints = false
    updateAvailableOverlayDot.isHidden = true

    bezelStyle = .toolbar
    addSubview(updateAvailableOverlayDot)

    NSLayoutConstraint.activate([
      updateAvailableOverlayDot.centerXAnchor.constraint(equalTo: trailingAnchor),
      updateAvailableOverlayDot.centerYAnchor.constraint(equalTo: topAnchor),
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override func viewWillMove(toWindow newWindow: NSWindow?) {
    super.viewWillMove(toWindow: newWindow)
    if newWindow == nil {
      updatesObservationTask?.cancel()
    } else {
      updatesObservationTask = Task { [weak self] in
        for await value in SparkleController.shared.stream() {
          self?.updateAvailableOverlayDot.isHidden = !value
        }
      }
    }
  }

  // MARK: Internal

  let updateAvailableOverlayDot = NSImageView(image: .init(named: NSImage.statusUnavailableName) ?? .init())

  // MARK: Private

  private var updatesObservationTask: Task<Void, Never>?
}
