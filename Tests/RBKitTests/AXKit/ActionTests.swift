import Testing
@testable import AXKit

@Suite
struct `Action Tests` {
  @Test
  func `actions have expected raw values`() {
    let actions: [(Action, String)] = [
      (.cancel, "AXCancel"),
      (.confirm, "AXConfirm"),
      (.decrement, "AXDecrement"),
      (.delete, "AXDelete"),
      (.increment, "AXIncrement"),
      (.pick, "AXPick"),
      (.press, "AXPress"),
      (.raise, "AXRaise"),
      (.showAlternateUI, "AXShowAlternateUI"),
      (.showDefaultUI, "AXShowDefaultUI"),
      (.showMenu, "AXShowMenu"),
      (.scrollToVisible, "AXScrollToVisible"),
    ]

    for (action, rawValue) in actions {
      #expect(action.rawValue == rawValue)
    }
  }
}
