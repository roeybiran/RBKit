import ApplicationServices
import Foundation
import Dependencies

public final class AXClientMock: AXClient {

  // MARK: Lifecycle

  public init() { }

  public let box: SpecializedBox = .init()

  // MARK: Public

  public typealias UIElement = UIElementMock
  public typealias UIElementValue = UIElementValueMock
  public typealias Observer = ObserverMock
  public typealias RunLoopSource = RunLoopSourceMock
  public typealias SpecializedBox = Box<ObserverCallback, ObserverCallbackWithInfo>

  public var _isProcessTrustedWithOptions: (CFDictionary?) -> Bool = { _ in unimplemented(placeholder: false) }

  public var _isProcessTrusted: () -> Bool = { unimplemented("_isProcessTrusted", placeholder: true) }

  public var _getTypeID: () -> CFTypeID = { CFStringGetTypeID() }

  public var _attributeNames: (UIElement, UnsafeMutablePointer<CFArray?>) -> AXError = { _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _attributeValue: (UIElement, CFString, UnsafeMutablePointer<CFTypeRef?>) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _getAttributeValueCount: (UIElement, CFString, UnsafeMutablePointer<CFIndex>) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _attributeValues: (UIElement, CFString, CFIndex, CFIndex, UnsafeMutablePointer<CFArray?>)
    -> AXError = { _, _, _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _isAttributeSettable: (UIElement, CFString, UnsafeMutablePointer<DarwinBoolean>) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _setAttributeValue: (UIElement, CFString, CFTypeRef) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _attributeValueMultiple: (UIElement, CFArray, AXCopyMultipleAttributeOptions, UnsafeMutablePointer<CFArray?>)
    -> AXError = { _, _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _actionNames: (UIElement, UnsafeMutablePointer<CFArray?>) -> AXError = { _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _actionDescription: (UIElement, CFString, UnsafeMutablePointer<CFString?>) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _performAction: (UIElement, CFString) -> AXError = { _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _elementAtPosition: (UIElement, Float, Float, UnsafeMutablePointer<UIElement?>) -> AXError = { _, _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _application: (pid_t) -> UIElement = { _ in unimplemented(placeholder: UIElementMock()) }

  public var _systemWide: () -> UIElement = { unimplemented(placeholder: UIElementMock()) }

  public var _getPid: (UIElement, UnsafeMutablePointer<pid_t>) -> AXError = { _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _setMessagingTimeout: (UIElement, Float) -> AXError = { _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _observerGetTypeID: () -> CFTypeID = { unimplemented(placeholder: CFStringGetTypeID()) }

  public var _observerCreate: (pid_t, @escaping (Observer, UIElement, CFString) -> Void, UnsafeMutablePointer<Observer?>)
    -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _observerCreateWithInfoCallback: (
    pid_t,
    @escaping (Observer, UIElement, CFString, CFDictionary) -> Void,
    UnsafeMutablePointer<Observer?>)
    -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _observerAddNotification: (Observer, UIElement, CFString) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _observerRemoveNotification: (Observer, UIElement, CFString) -> AXError = { _, _, _ in unimplemented(placeholder: .apiDisabled) }

  public var _observerGetRunLoopSource: (Observer) -> RunLoopSourceMock = { _ in unimplemented(placeholder: RunLoopSourceMock()) }

  public var _getAXValueTypeID: () -> CFTypeID = { unimplemented(placeholder: AXValueGetTypeID()) }

  public var _createAXValue: (AXValueType, UnsafeRawPointer) -> UIElementValue? = { _, _ in unimplemented(placeholder: nil) }

  public var _getAXValueType: (UIElementValue) -> AXValueType = { _ in unimplemented(placeholder: .cgPoint) }

  public var _getAXValueValue: (UIElementValue, AXValueType, UnsafeMutableRawPointer) -> Bool = { _, _, _ in unimplemented(placeholder: false) }

  public var _addRunLoopSource: (CFRunLoop, RunLoopSource, CFRunLoopMode) -> Void = { _, _, _ in unimplemented(placeholder: ()) }

  public var _removeRunLoopSource: (CFRunLoop, RunLoopSource, CFRunLoopMode) -> Void = { _, _, _ in unimplemented(placeholder: ()) }

  public var _getWindow: (UIElement, inout CGWindowID) -> AXError = { _, _ in unimplemented(placeholder: .apiDisabled) }

  // MARK: - Process Trust
  
  public func isProcessTrustedWithOptions(_ options: CFDictionary?) -> Bool {
    _isProcessTrustedWithOptions(options)
  }

  public func isProcessTrusted() -> Bool {
    _isProcessTrusted()
  }

  // MARK: - AXUIElement

  public func getTypeID() -> CFTypeID {
    _getTypeID()
  }

  public func attributeNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError {
    _attributeNames(element, names)
  }

  public func attributeValue(element: UIElement, attribute: CFString, value: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
    _attributeValue(element, attribute, value)
  }

  public func getAttributeValueCount(element: UIElement, attribute: CFString, count: UnsafeMutablePointer<CFIndex>) -> AXError {
    _getAttributeValueCount(element, attribute, count)
  }

  public func attributeValues(
    element: UIElement,
    attribute: CFString,
    index: CFIndex,
    maxValues: CFIndex,
    values: UnsafeMutablePointer<CFArray?>)
    -> AXError
  {
    _attributeValues(element, attribute, index, maxValues, values)
  }

  public func isAttributeSettable(
    element: UIElement,
    attribute: CFString,
    settable: UnsafeMutablePointer<DarwinBoolean>)
    -> AXError
  {
    _isAttributeSettable(element, attribute, settable)
  }

  public func setAttributeValue(element: UIElement, attribute: CFString, value: CFTypeRef) -> AXError {
    _setAttributeValue(element, attribute, value)
  }

  public func multipleAttributeValues(
    element: UIElement,
    attributes: CFArray,
    options: AXCopyMultipleAttributeOptions,
    values: UnsafeMutablePointer<CFArray?>)
    -> AXError
  {
    _attributeValueMultiple(element, attributes, options, values)
  }

  public func actionNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError {
    _actionNames(element, names)
  }

  public func actionDescription(element: UIElement, action: CFString, description: UnsafeMutablePointer<CFString?>) -> AXError {
    _actionDescription(element, action, description)
  }

  public func performAction(element: UIElement, action: CFString) -> AXError {
    _performAction(element, action)
  }

  public func elementAtPosition(
    application: UIElement,
    x: Float,
    y: Float,
    element: UnsafeMutablePointer<UIElement?>)
    -> AXError
  {
    _elementAtPosition(application, x, y, element)
  }

  public func application(pid: pid_t) -> UIElement {
    _application(pid)
  }

  public func systemWide() -> UIElement {
    _systemWide()
  }

  public func getPid(element: UIElement, pid: UnsafeMutablePointer<pid_t>) -> AXError {
    _getPid(element, pid)
  }

  public func setMessagingTimeout(element: UIElement, timeoutInSeconds: Float) -> AXError {
    _setMessagingTimeout(element, timeoutInSeconds)
  }

  // MARK: - AXObserver

  public func observerGetTypeID() -> CFTypeID {
    _observerGetTypeID()
  }

  public func observerCreate(application: pid_t, outObserver: UnsafeMutablePointer<Observer?>) -> AXError {
    _observerCreate(application, { _, _, _ in }, outObserver)
  }

  public func observerCreateWithInfoCallback(application: pid_t, outObserver: UnsafeMutablePointer<Observer?>) -> AXError {
    _observerCreateWithInfoCallback(application, { _, _, _, _ in }, outObserver)
  }

  public func observerAddNotification(observer: Observer, element: UIElement, notification: CFString, refcon: UnsafeMutableRawPointer?) -> AXError {
    _observerAddNotification(observer, element, notification)
  }

  public func observerRemoveNotification(observer: Observer, element: UIElement, notification: CFString) -> AXError {
    _observerRemoveNotification(observer, element, notification)
  }

  public func observerGetRunLoopSource(observer: Observer) -> RunLoopSourceMock {
    _observerGetRunLoopSource(observer)
  }

  // MARK: - AXValue

  public func getAXValueTypeID() -> CFTypeID {
    _getAXValueTypeID()
  }

  public func createAXValue(_ theType: AXValueType, _ valuePtr: UnsafeRawPointer) -> UIElementValue? {
    _createAXValue(theType, valuePtr)
  }

  public func getAXValueType(_ value: UIElementValue) -> AXValueType {
    _getAXValueType(value)
  }

  public func getAXValueValue(_ value: UIElementValue, _ theType: AXValueType, _ valuePtr: UnsafeMutableRawPointer) -> Bool {
    _getAXValueValue(value, theType, valuePtr)
  }

  // MARK: - CFRunLoopSource

  public func addRunLoopSource(runLoop: CFRunLoop!, source: RunLoopSource!, mode: CFRunLoopMode!) {
    _addRunLoopSource(runLoop, source, mode)
  }

  public func removeRunLoopSource(runLoop: CFRunLoop!, source: RunLoopSource!, mode: CFRunLoopMode!) {
    _removeRunLoopSource(runLoop, source, mode)
  }

  // MARK: - Private APIs

  public func _getWindow(_ axUiElement: UIElement, _ wid: inout CGWindowID) -> AXError {
    _getWindow(axUiElement, &wid)
  }
}
