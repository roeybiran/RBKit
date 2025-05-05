import SwiftUI

public struct HelpButton: NSViewRepresentable {

  // MARK: Lifecycle

  public init(tooltip: String = "Help", action: @escaping () -> Void) {
    self.tooltip = tooltip
    self.action = action
  }

  // MARK: Public

  public class Coordinator: NSObject {

    // MARK: Lifecycle

    init(action: @escaping () -> Void) {
      self.action = action
    }

    // MARK: Internal

    let action: () -> Void

    @objc
    func buttonClicked() {
      action()
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(action: action)
  }

  public func makeNSView(context: Context) -> NSButton {
    let button = NSButton(title: "", target: context.coordinator, action: #selector(Coordinator.buttonClicked))
    button.toolTip = tooltip
    button.bezelStyle = .helpButton
    return button
  }

  public func updateNSView(_: NSButton, context _: Context) { }

  // MARK: Internal

  var tooltip: String
  var action: () -> Void

}

#Preview {
  HelpButton {
    print("help!")
  }
}
