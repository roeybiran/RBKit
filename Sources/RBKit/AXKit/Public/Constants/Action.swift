// swiftformat:disable organizeDeclarations
public enum Action: String, Sendable {
  case cancel = "AXCancel"
  case confirm = "AXConfirm"
  case decrement = "AXDecrement"
  case delete = "AXDelete"
  case increment = "AXIncrement"
  case pick = "AXPick"
  case press = "AXPress"
  case raise = "AXRaise"
  case showAlternateUI = "AXShowAlternateUI"
  case showDefaultUI = "AXShowDefaultUI"
  case showMenu = "AXShowMenu"

  // MARK: - Undocumented

  case scrollToVisible = "AXScrollToVisible"
}

// swiftformat:enable organizeDeclarations
