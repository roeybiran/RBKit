import SwiftUI

public struct HelpButton: NSViewRepresentable {
  var tooltip: String
  var action: () -> Void

  public init(tooltip: String = "Help", action: @escaping () -> Void) {
    self.tooltip = tooltip
    self.action = action
  }

  public class Coordinator: NSObject {
    let action: () -> Void

    init(action: @escaping () -> Void) {
      self.action = action
    }

    @objc func buttonClicked() {
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

  public func updateNSView(_ nsView: NSButton, context: Context) { }
}

#Preview {
  HelpButton {
    print("help!")
  }
}
