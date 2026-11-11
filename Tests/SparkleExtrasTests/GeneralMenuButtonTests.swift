import AppKit
import Testing
@testable import SparkleExtras

@Suite(.serialized)
@MainActor
struct GeneralMenuButtonTests {
  @Test
  func `init(), should configure overlay and menu wiring`() {
    let menu = NSMenu()
    let firstItem = NSMenuItem(title: "first", action: nil, keyEquivalent: "")
    let secondItem = NSMenuItem(title: "second", action: nil, keyEquivalent: "")
    menu.addItem(firstItem)
    menu.addItem(secondItem)
    let sut = GeneralMenuButton()
    sut.menu = menu
    #expect(sut.bezelStyle == .toolbar)
    #expect(sut.subviews.contains(sut.updateAvailableOverlayDot))
    #expect(menu.items.count == 2)
    #expect(menu.items[0] === firstItem)
    #expect(menu.items[1] === secondItem)
    #expect(sut.constraints.count == 2)
    #expect(sut.constraints[0].firstAttribute == .centerX)
    #expect(sut.constraints[0].secondAttribute == .trailing)
    #expect(sut.constraints[1].firstAttribute == .centerY)
    #expect(sut.constraints[1].secondAttribute == .top)
    #expect(!sut.updateAvailableOverlayDot.translatesAutoresizingMaskIntoConstraints)
    #expect(sut.updateAvailableOverlayDot.isHidden)
    #expect(sut.updateAvailableOverlayDot.image != nil)
  }

  @Test
  func `viewWillMove(toWindow:), with window, should keep overlay configured`() {
    let sut = GeneralMenuButton()
    sut.menu = NSMenu()

    sut.viewWillMove(toWindow: NSWindow())

    #expect(sut.subviews.contains(sut.updateAvailableOverlayDot))
    #expect(!sut.updateAvailableOverlayDot.translatesAutoresizingMaskIntoConstraints)
  }

  @Test
  func `viewWillMove(toWindow:), with nil window, should not affect menu configuration`() {
    let sut = GeneralMenuButton()
    let menu = NSMenu()
    let menuItem = NSMenuItem(title: "item", action: nil, keyEquivalent: "")
    menu.addItem(menuItem)
    sut.menu = menu

    sut.viewWillMove(toWindow: nil)

    #expect(menu.items.count == 1)
    #expect(menu.items[0] === menuItem)
  }
}
