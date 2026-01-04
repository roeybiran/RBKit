@preconcurrency import ApplicationServices
import Dependencies
import DependenciesMacros
import Foundation
import CoreFoundation

// MARK: - AXClient

public protocol AXClient: Sendable {
  typealias AXObject = AnyObject & Hashable & Sendable
  associatedtype UIElement: AXObject
  associatedtype UIElementValue: AXObject
  associatedtype Observer: AXObject
  associatedtype RunLoopSource: AXObject

  typealias ObserverCallback = (Observer, UIElement, CFString) -> Void
  typealias ObserverCallbackWithInfo = (Observer, UIElement, CFString, CFDictionary) -> Void

  // Process Trust
  func isProcessTrustedWithOptions(_ options: CFDictionary?) -> Bool
  func isProcessTrusted() -> Bool

  // AXUIElement
  func getTypeID() -> CFTypeID
  func attributeNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError
  func attributeValue(element: UIElement, attribute: CFString, value: UnsafeMutablePointer<CFTypeRef?>) -> AXError
  func getAttributeValueCount(element: UIElement, attribute: CFString, count: UnsafeMutablePointer<CFIndex>) -> AXError
  func attributeValues(
    element: UIElement,
    attribute: CFString,
    index: CFIndex,
    maxValues: CFIndex,
    values: UnsafeMutablePointer<CFArray?>) -> AXError
  func isAttributeSettable(element: UIElement, attribute: CFString, settable: UnsafeMutablePointer<DarwinBoolean>) -> AXError
  func setAttributeValue(element: UIElement, attribute: CFString, value: CFTypeRef) -> AXError
  func multipleAttributeValues(
    element: UIElement,
    attributes: CFArray,
    options: AXCopyMultipleAttributeOptions,
    values: UnsafeMutablePointer<CFArray?>) -> AXError
  // func parameterizedAttributeNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError
  // func parameterizedAttributeValue(element: UIElement, parameterizedAttribute: CFString, parameter: CFTypeRef, result: UnsafeMutablePointer<CFTypeRef?>) -> AXError
  func actionNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError
  func actionDescription(element: UIElement, action: CFString, description: UnsafeMutablePointer<CFString?>) -> AXError
  func performAction(element: UIElement, action: CFString) -> AXError
  func elementAtPosition(application: UIElement, x: Float, y: Float, element: UnsafeMutablePointer<UIElement?>) -> AXError
  func application(pid: pid_t) -> UIElement
  func systemWide() -> UIElement
  func getPid(element: UIElement, pid: UnsafeMutablePointer<pid_t>) -> AXError
  func setMessagingTimeout(element: UIElement, timeoutInSeconds: Float) -> AXError

  // AXTextMarker
  // func textMarkerTypeID() -> CFTypeID
  // func textMarker(allocator: CFAllocator?, bytes: UnsafePointer<UInt8>, length: CFIndex) -> AXTextMarker
  // func textMarkerLength(marker: AXTextMarker) -> CFIndex
  // func textMarkerBytePtr(marker: AXTextMarker) -> UnsafePointer<UInt8>

  // AXTextMarkerRange
  // func textMarkerRangeTypeID() -> CFTypeID
  // func textMarkerRange(allocator: CFAllocator?, startMarker: AXTextMarker, endMarker: AXTextMarker) -> AXTextMarkerRange
  // func textMarkerRangeWithBytes(allocator: CFAllocator?, startMarkerBytes: UnsafePointer<UInt8>, startMarkerLength: CFIndex, endMarkerBytes: UnsafePointer<UInt8>, endMarkerLength: CFIndex) -> AXTextMarkerRange
  // func textMarkerRangeStartMarker(textMarkerRange: AXTextMarkerRange) -> AXTextMarker
  // func textMarkerRangeEndMarker(textMarkerRange: AXTextMarkerRange) -> AXTextMarker

  // AXObserver
  func observerGetTypeID() -> CFTypeID
  func observerCreate(application: pid_t, outObserver: UnsafeMutablePointer<Observer?>) -> AXError
  func observerCreateWithInfoCallback(application: pid_t, outObserver: UnsafeMutablePointer<Observer?>) -> AXError
  func observerAddNotification(observer: Observer, element: UIElement, notification: CFString, refcon: UnsafeMutableRawPointer?) -> AXError
  func observerRemoveNotification(observer: Observer, element: UIElement, notification: CFString) -> AXError
  func observerGetRunLoopSource(observer: Observer) -> RunLoopSource

  // AXValue.h
  func getAXValueTypeID() -> CFTypeID
  func createAXValue(_ theType: AXValueType, _ valuePtr: UnsafeRawPointer) -> UIElementValue?
  func getAXValueType(_ value: UIElementValue) -> AXValueType
  func getAXValueValue(_ value: UIElementValue, _ theType: AXValueType, _ valuePtr: UnsafeMutableRawPointer) -> Bool

  // Private APIs
  func _getWindow(_ axUiElement: UIElement, _ wid: inout CGWindowID) -> AXError
}

extension AXClient {
  // MARK: Public

  @discardableResult
  public func isProcessTrusted(usePrompt: Bool) -> Bool {
    let preflight = isProcessTrusted()
    if usePrompt && !preflight {
      let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): kCFBooleanTrue] as CFDictionary
      return isProcessTrustedWithOptions(opts)
    } else {
      return preflight
    }
  }

  public func attributeNames(element: UIElement) throws(AXClientError) -> [String] {
    var names: CFArray?
    let result = attributeNames(element: element, names: &names)
    guard result == .success else { throw AXClientError(axError: result) }
    return ((names as? [CFString]) as? [String]) ?? []
  }

  public func attributeValue<A>(element: UIElement, for a0: Attribute<A>) throws(AXClientError) -> A {
    var value: CFTypeRef?
    let result = attributeValue(element: element, attribute: a0.name as CFString, value: &value)
    guard result == .success else { throw AXClientError(axError: result) }
    guard let value = value.map(decode) as? A else {
      // TODO: Swift 6.2 `processToExit`
      // assertionFailure("The accessibility API returned no error yet casting failed. This shouldn't happen.")
      throw .attributeUnsupported
    }
    return value
  }

  public func getAttributeValueCount(element: UIElement, attribute: String) throws(AXClientError) -> Int {
    var count: CFIndex = 0
    let result = getAttributeValueCount(element: element, attribute: attribute as CFString, count: &count)
    guard result == .success else { throw AXClientError(axError: result) }
    return Int(count)
  }

  public func attributeValues(element: UIElement, attribute: String, index: Int, maxValues: Int) throws(AXClientError) -> [Any]? {
    var values: CFArray?
    let result = attributeValues(
      element: element,
      attribute: attribute as CFString,
      index: CFIndex(index),
      maxValues: CFIndex(maxValues),
      values: &values)
    guard result == .success else { throw AXClientError(axError: result) }
    return values as? [Any]
  }

  public func isAttributeSettable<T>(element: UIElement, attribute: Attribute<T>) throws(AXClientError) -> Bool {
    var settable = DarwinBoolean(false)
    let result = isAttributeSettable(element: element, attribute: attribute.name as CFString, settable: &settable)
    guard result == .success else { throw AXClientError(axError: result) }
    return settable.boolValue
  }

  public func setAttributeValue<A>(element: UIElement, attribute: Attribute<A>, value: A) throws(AXClientError) {
    let result = setAttributeValue(element: element, attribute: attribute.name as CFString, value: encode(value))
    guard result == .success else { throw AXClientError(axError: result) }
  }

  public func attributeValue<A0, A1>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?)
  {
    let results = try multipleAttributeValues(element: element, for: [a0.name, a1.name], stopOnError: stopOnError)
    return (results[0] as? A0, results[1] as? A1)
  }

  public func attributeValue<A0, A1, A2>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    _ a2: Attribute<A2>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?, A2?)
  {
    let results = try multipleAttributeValues(element: element, for: [a0.name, a1.name, a2.name], stopOnError: stopOnError)
    return (
      results[0] as? A0,
      results[1] as? A1,
      results[2] as? A2)
  }

  public func attributeValue<A0, A1, A2, A3>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    _ a2: Attribute<A2>,
    _ a3: Attribute<A3>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?, A2?, A3?)
  {
    let results = try multipleAttributeValues(
      element: element,
      for: [a0.name, a1.name, a2.name, a3.name],
      stopOnError: stopOnError)
    return (
      results[0] as? A0,
      results[1] as? A1,
      results[2] as? A2,
      results[3] as? A3)
  }

  public func attributeValue<A0, A1, A2, A3, A4>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    _ a2: Attribute<A2>,
    _ a3: Attribute<A3>,
    _ a4: Attribute<A4>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?, A2?, A3?, A4?)
  {
    let results = try multipleAttributeValues(
      element: element,
      for: [a0.name, a1.name, a2.name, a3.name, a4.name],
      stopOnError: stopOnError)
    return (
      results[0] as? A0,
      results[1] as? A1,
      results[2] as? A2,
      results[3] as? A3,
      results[4] as? A4)
  }

  public func attributeValue<A0, A1, A2, A3, A4, A5>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    _ a2: Attribute<A2>,
    _ a3: Attribute<A3>,
    _ a4: Attribute<A4>,
    _ a5: Attribute<A5>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?, A2?, A3?, A4?, A5?)
  {
    let results = try multipleAttributeValues(
      element: element,
      for: [a0.name, a1.name, a2.name, a3.name, a4.name, a5.name],
      stopOnError: stopOnError)
    return (
      results[0] as? A0,
      results[1] as? A1,
      results[2] as? A2,
      results[3] as? A3,
      results[4] as? A4,
      results[5] as? A5)
  }

  public func attributeValue<A0, A1, A2, A3, A4, A5, A6>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    _ a2: Attribute<A2>,
    _ a3: Attribute<A3>,
    _ a4: Attribute<A4>,
    _ a5: Attribute<A5>,
    _ a6: Attribute<A6>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?, A2?, A3?, A4?, A5?, A6?)
  {
    let results = try multipleAttributeValues(
      element: element,
      for: [a0.name, a1.name, a2.name, a3.name, a4.name, a5.name, a6.name],
      stopOnError: stopOnError)
    return (
      results[0] as? A0,
      results[1] as? A1,
      results[2] as? A2,
      results[3] as? A3,
      results[4] as? A4,
      results[5] as? A5,
      results[6] as? A6)
  }

  public func attributeValue<A0, A1, A2, A3, A4, A5, A6, A7>(
    element: UIElement,
    for a0: Attribute<A0>,
    _ a1: Attribute<A1>,
    _ a2: Attribute<A2>,
    _ a3: Attribute<A3>,
    _ a4: Attribute<A4>,
    _ a5: Attribute<A5>,
    _ a6: Attribute<A6>,
    _ a7: Attribute<A7>,
    stopOnError: Bool = false)
  throws(AXClientError) -> (A0?, A1?, A2?, A3?, A4?, A5?, A6?, A7?)
  {
    let results = try multipleAttributeValues(
      element: element,
      for: [a0.name, a1.name, a2.name, a3.name, a4.name, a5.name, a6.name, a7.name],
      stopOnError: stopOnError)
    return (
      results[0] as? A0,
      results[1] as? A1,
      results[2] as? A2,
      results[3] as? A3,
      results[4] as? A4,
      results[5] as? A5,
      results[6] as? A6,
      results[7] as? A7)
  }

  public func actionNames(element: UIElement) throws -> [String] {
    var names: CFArray?
    let result = actionNames(element: element, names: &names)
    guard result == .success, let cfArray = names as? [CFString] else { throw AXClientError(axError: result) }
    return cfArray.map { $0 as String }
  }

  public func actionDescription(element: UIElement, action: Action) throws(AXClientError) -> String? {
    var description: CFString?
    let result = actionDescription(element: element, action: action.rawValue as CFString, description: &description)
    guard result == .success else { throw AXClientError(axError: result) }
    return description as? String
  }

  public func performAction(element: UIElement, action: Action) throws(AXClientError) {
    let result = performAction(element: element, action: action.rawValue as CFString)
    guard result == .success else { throw AXClientError(axError: result) }
  }

  public func elementAtPosition(application: UIElement, x: Float, y: Float) throws -> UIElement? {
    var element: UIElement?
    let result = elementAtPosition(application: application, x: x, y: y, element: &element)
    guard result == .success else { throw AXClientError(axError: result) }
    return element
  }

  public func getPid(element: UIElement) throws -> pid_t {
    var pid: pid_t = 0
    let result = getPid(element: element, pid: &pid)
    guard result == .success else { throw AXClientError(axError: result) }
    return pid
  }

  public func getWindowID(of element: UIElement) throws(AXClientError) -> CGWindowID {
    var wid = CGWindowID()
    let result = _getWindow(element, &wid)
    guard result == .success else { throw AXClientError(axError: result) }
    if wid == kCGNullWindowID { }
    // https://github.com/lwouis/alt-tab-macos/blob/b325cc75c02ea6685e9adef93e49a8a1700062fb/src/logic/Windows.swift#L320
    if wid == CGWindowID(bitPattern: -1) { }
    return wid
  }

  // MARK: Private

  private func multipleAttributeValues(
    element: UIElement,
    for attributes: [String],
    stopOnError: Bool = false)
  throws(AXClientError) -> [Any?]
  {
    let options: AXCopyMultipleAttributeOptions = stopOnError ? .stopOnError : []

    var values: CFArray?

    let result = multipleAttributeValues(element: element, attributes: attributes as CFArray, options: options, values: &values)
    guard result == .success else { throw AXClientError(axError: result) }

    let transformed: [Any?]
    if let values {
      transformed = (values as [AnyObject]).map(decode)
    } else {
      // TODO: Swift 6.2 `processToExit`
      // assertionFailure("Accessibility API reported no errors but copied value is nil")
      transformed = Array(repeating: nil, count: attributes.count)
    }
    return transformed
  }

  private func decode(_ value: AnyObject) -> Any {
    // TODO: should CFGetTypeID be a dependency?
    if CFGetTypeID(value) == getAXValueTypeID() {
      let castValue = value as! UIElementValue
      switch getAXValueType(castValue) {
      case .cgPoint:
        var defaultValue = CGPoint()
        let result = getAXValueValue(castValue, .cgPoint, &defaultValue)
        assert(result)
        return defaultValue

      case .cgRect:
        var defaultValue = CGRect()
        let result = getAXValueValue(castValue, .cgRect, &defaultValue)
        assert(result)
        return defaultValue

      case .cgSize:
        var defaultValue = CGSize()
        let result = getAXValueValue(castValue, .cgSize, &defaultValue)
        assert(result)
        return defaultValue

      case .cfRange:
        var defaultValue = CFRange()
        let result = getAXValueValue(castValue, .cfRange, &defaultValue)
        assert(result)
        return defaultValue

      case .axError:
        var defaultValue = AXError.success
        let result = getAXValueValue(castValue, .axError, &defaultValue)
        assert(result)
        return defaultValue

      case .illegal:
        fallthrough

      @unknown default:
        // TODO: Swift 6.2 `processToExit`
        // assertionFailure()
        return value
      }
    } else {
      return value
    }
  }

  private func encode(_ value: Any) -> AnyObject {
    switch value {
    case var value as CFRange:
      guard let rangeValue = createAXValue(.cfRange, &value) else { break }
      return rangeValue
    case var value as CGPoint:
      guard let pointValue = createAXValue(.cgPoint, &value) else { break }
      return pointValue
    case var value as CGRect:
      guard let rectValue = createAXValue(.cgRect, &value) else { break }
      return rectValue
    case var value as CGSize:
      guard let sizeValue = createAXValue(.cgSize, &value) else { break }
      return sizeValue
    default:
      break
    }
    return value as AnyObject // must be an object to pass to AX
  }

  public var AMPMField: Attribute<UIElement> { .init(.AMPMField) }
  public var cancelButton: Attribute<UIElement> { .init(.cancelButton) }
  public var children: Attribute<[UIElement]> { .init(.children) }
  public var closeButton: Attribute<UIElement> { .init(.closeButton) }
  public var columns: Attribute<[UIElement]> { .init(.columns) }
  public var contents: Attribute<[UIElement]> { .init(.contents) }
  public var dayField: Attribute<UIElement> { .init(.dayField) }
  public var decrementButton: Attribute<UIElement> { .init(.decrementButton) }
  public var defaultButton: Attribute<UIElement> { .init(.defaultButton) }
  public var disclosedByRow: Attribute<UIElement> { .init(.disclosedByRow) }
  public var disclosedRows: Attribute<[UIElement]> { .init(.disclosedRows) }
  public var extrasMenuBar: Attribute<UIElement> { .init(.extrasMenuBar) }
  public var focusedUIElement: Attribute<UIElement> { .init(.focusedUIElement) }
  public var focusedWindow: Attribute<UIElement> { .init(.focusedWindow) }
  public var fullScreenButton: Attribute<UIElement> { .init(.fullScreenButton) }
  public var growArea: Attribute<UIElement> { .init(.growArea) }
  public var header: Attribute<UIElement> { .init(.header) }
  public var horizontalScrollBar: Attribute<UIElement> { .init(.horizontalScrollBar) }
  public var hourField: Attribute<UIElement> { .init(.hourField) }
  public var incrementButton: Attribute<UIElement> { .init(.incrementButton) }
  public var incrementor: Attribute<UIElement> { .init(.incrementor) }
  public var labelUIElements: Attribute<[UIElement]> { .init(.labelUIElements) }
  public var linkedUIElements: Attribute<[UIElement]> { .init(.linkedUIElements) }
  public var mainWindow: Attribute<UIElement> { .init(.mainWindow) }
  public var markerUIElements: Attribute<UIElement> { .init(.markerUIElements) }
  public var matteContentUIElement: Attribute<UIElement> { .init(.matteContentUIElement) }
  public var menuBar: Attribute<UIElement> { .init(.menuBar) }
  public var menuItemPrimaryUIElement: Attribute<UIElement> { .init(.menuItemPrimaryUIElement) }
  public var minimizeButton: Attribute<UIElement> { .init(.minimizeButton) }
  public var minuteField: Attribute<UIElement> { .init(.minuteField) }
  public var monthField: Attribute<UIElement> { .init(.monthField) }
  public var nextContents: Attribute<[UIElement]> { .init(.nextContents) }
  public var overflowButton: Attribute<UIElement> { .init(.overflowButton) }
  public var parent: Attribute<UIElement> { .init(.parent) }
  public var previousContents: Attribute<[UIElement]> { .init(.previousContents) }
  public var proxy: Attribute<UIElement> { .init(.proxy) }
  public var rows: Attribute<[UIElement]> { .init(.rows) }
  public var secondField: Attribute<UIElement> { .init(.secondField) }
  public var selectedChildren: Attribute<[UIElement]> { .init(.selectedChildren) }
  public var selectedColumns: Attribute<[UIElement]> { .init(.selectedColumns) }
  public var selectedRows: Attribute<[UIElement]> { .init(.selectedRows) }
  public var sharedFocusElements: Attribute<[UIElement]> { .init(.sharedFocusElements) }
  public var sharedTextUIElements: Attribute<[UIElement]> { .init(.sharedTextUIElements) }
  public var shownMenuUIElement: Attribute<UIElement> { .init(.shownMenuUIElement) }
  public var splitters: Attribute<[UIElement]> { .init(.splitters) }
  public var tabs: Attribute<[UIElement]> { .init(.tabs) }
  public var titleUIElement: Attribute<UIElement> { .init(.titleUIElement) }
  public var toolbarButton: Attribute<UIElement> { .init(.toolbarButton) }
  public var topLevelUIElement: Attribute<UIElement> { .init(.topLevelUIElement) }
  public var verticalScrollBar: Attribute<UIElement> { .init(.verticalScrollBar) }
  public var visibleChildren: Attribute<[UIElement]> { .init(.visibleChildren) }
  public var visibleColumns: Attribute<[UIElement]> { .init(.visibleColumns) }
  public var visibleRows: Attribute<[UIElement]> { .init(.visibleRows) }
  public var window: Attribute<UIElement> { .init(.window) }
  public var windows: Attribute<[UIElement]> { .init(.windows) }
  public var yearField: Attribute<UIElement> { .init(.yearField) }
  public var zoomButton: Attribute<UIElement> { .init(.zoomButton) }
  public var focusedApplication: Attribute<UIElement> { .init(.focusedApplication) }
}

