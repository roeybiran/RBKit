// AXActionConstants.h

public enum Action: String {
  // standard actions
  case press = "AXPress"
  case increment = "AXIncrement"
  case decrement = "AXDecrement"
  case confirm = "AXConfirm"
  case cancel = "AXCancel"
  case showAlternateUI = "AXShowAlternateUI"
  case showDefaultUI = "AXShowDefaultUI"
  // new actions
  case raise = "AXRaise"
  case showMenu = "AXShowMenu"
  /// obsolete
  case pick = "AXPick"
}
