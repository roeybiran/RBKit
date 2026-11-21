import AppKit
import Carbon

// MARK: - Modifiers

public struct Modifiers: Hashable, Sendable {
  public let carbon: Int
  public let cocoa: UInt
  public let symbols: String

  public var modifierFlags: NSEvent.ModifierFlags {
    NSEvent.ModifierFlags(rawValue: cocoa)
  }
}

extension Modifiers {
  public init(carbon: Int) {
    var cocoa = NSEvent.ModifierFlags()

    if carbon & controlKey == controlKey {
      cocoa.insert(.control)
    }
    if carbon & optionKey == optionKey {
      cocoa.insert(.option)
    }
    if carbon & shiftKey == shiftKey {
      cocoa.insert(.shift)
    }
    if carbon & cmdKey == cmdKey {
      cocoa.insert(.command)
    }

    let filteredCocoa = cocoa.intersection(.deviceIndependentFlagsMask).subtracting([
      .capsLock,
      .numericPad,
      .help,
      .function,
    ])

    var filteredCarbon = 0
    if filteredCocoa.contains(.control) {
      filteredCarbon |= controlKey
    }
    if filteredCocoa.contains(.option) {
      filteredCarbon |= optionKey
    }
    if filteredCocoa.contains(.shift) {
      filteredCarbon |= shiftKey
    }
    if filteredCocoa.contains(.command) {
      filteredCarbon |= cmdKey
    }

    self.carbon = filteredCarbon
    self.cocoa = filteredCocoa.rawValue
    symbols = [
      (NSEvent.ModifierFlags.control, kControlUnicode),
      (.option, kOptionUnicode),
      (.shift, kShiftUnicode),
      (.command, kCommandUnicode),
    ]
    .filter {
      filteredCocoa.contains($0.0)
    }
    .map {
      String(format: "%C", $0.1)
    }
    .reduce("", +)
  }

  /// Converting to Cocoa modifiers first is important.
  public init(cocoa: NSEvent.ModifierFlags) {
    var carbon = 0

    if cocoa.contains(.control) {
      carbon |= controlKey
    }
    if cocoa.contains(.option) {
      carbon |= optionKey
    }
    if cocoa.contains(.shift) {
      carbon |= shiftKey
    }
    if cocoa.contains(.command) {
      carbon |= cmdKey
    }

    self.init(carbon: carbon)
  }
}

// MARK: CustomStringConvertible

extension Modifiers: CustomStringConvertible {
  public var description: String {
    symbols
  }
}

// MARK: ExpressibleByArrayLiteral

extension Modifiers: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: NSEvent.ModifierFlags...) {
    var flags = NSEvent.ModifierFlags()
    for element in elements {
      flags.insert(element)
    }
    self.init(cocoa: flags)
  }
}
