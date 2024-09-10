import AppKit

public class DockVisualEffectView: NSVisualEffectView {
  public override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    blendingMode = .behindWindow
    material = .fullScreenUI
  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
