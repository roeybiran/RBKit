import Testing
@testable import AXKit

@Suite
struct `SubRole Tests` {
  @Test
  func `subroles have expected raw values`() {
    let subroles: [(SubRole, String)] = [
      (.dialog, "AXDialog"),
      (.floatingWindow, "AXFloatingWindow"),
      (.menuBarExtra, "AXMenuExtra"),
      (.standardWindow, "AXStandardWindow"),
      (.systemDialog, "AXSystemDialog"),
      (.systemFloatingWindow, "AXSystemFloatingWindow"),
      (.unknown, "AXUnknown"),
    ]

    for (subrole, rawValue) in subroles {
      #expect(subrole.rawValue == rawValue)
    }
  }
}
