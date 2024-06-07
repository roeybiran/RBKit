import AppKit

extension NSVisualEffectView {
  public static func dockStyle() -> NSVisualEffectView {
    let instance = NSVisualEffectView()
    instance.blendingMode = .behindWindow
    instance.material = .fullScreenUI
    return instance
  }
}
