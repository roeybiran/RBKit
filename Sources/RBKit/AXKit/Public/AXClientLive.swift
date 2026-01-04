@preconcurrency import ApplicationServices

// MARK: - AXClientLive

public struct AXClientLive: AXClient {

  // MARK: Public

  public init() { }

  public typealias UIElement = AXUIElement
  public typealias UIElementValue = AXValue
  public typealias Observer = AXObserver
  public typealias RunLoopSource = CFRunLoopSource


  // MARK: - Process Trust
  public func isProcessTrustedWithOptions(_ options: CFDictionary?) -> Bool {
    AXIsProcessTrustedWithOptions(options)
  }

  public func isProcessTrusted() -> Bool {
    AXIsProcessTrusted()
  }

  // MARK: - UIElement
  public func getTypeID() -> CFTypeID {
    AXUIElementGetTypeID()
  }

  public func attributeNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError {
    AXUIElementCopyAttributeNames(element, names)
  }

  public func attributeValue(element: UIElement, attribute: CFString, value: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
    AXUIElementCopyAttributeValue(element, attribute, value)
  }

  public func getAttributeValueCount(element: UIElement, attribute: CFString, count: UnsafeMutablePointer<CFIndex>) -> AXError {
    AXUIElementGetAttributeValueCount(element, attribute, count)
  }

  public func attributeValues(
    element: UIElement,
    attribute: CFString,
    index: CFIndex,
    maxValues: CFIndex,
    values: UnsafeMutablePointer<CFArray?>)
    -> AXError
  {
    AXUIElementCopyAttributeValues(element, attribute, index, maxValues, values)
  }

  public func isAttributeSettable(
    element: UIElement,
    attribute: CFString,
    settable: UnsafeMutablePointer<DarwinBoolean>)
    -> AXError
  {
    AXUIElementIsAttributeSettable(element, attribute, settable)
  }

  public func setAttributeValue(element: UIElement, attribute: CFString, value: CFTypeRef) -> AXError {
    AXUIElementSetAttributeValue(element, attribute, value)
  }

  public func multipleAttributeValues(
    element: UIElement,
    attributes: CFArray,
    options: AXCopyMultipleAttributeOptions,
    values: UnsafeMutablePointer<CFArray?>)
    -> AXError
  {
    AXUIElementCopyMultipleAttributeValues(element, attributes, options, values)
  }

  // func parameterizedAttributeNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError { fatalError("TODO") }
  // func parameterizedAttributeValue(element: UIElement, parameterizedAttribute: CFString, parameter: CFTypeRef, result: UnsafeMutablePointer<CFTypeRef?>) -> AXError { fatalError("TODO") }

  public func actionNames(element: UIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError {
    AXUIElementCopyActionNames(element, names)
  }

  public func actionDescription(element: UIElement, action: CFString, description: UnsafeMutablePointer<CFString?>) -> AXError {
    AXUIElementCopyActionDescription(element, action, description)
  }

  public func performAction(element: UIElement, action: CFString) -> AXError {
    AXUIElementPerformAction(element, action)
  }

  public func elementAtPosition(
    application: UIElement,
    x: Float,
    y: Float,
    element: UnsafeMutablePointer<UIElement?>)
    -> AXError
  {
    AXUIElementCopyElementAtPosition(application, x, y, element)
  }

  public func application(pid: pid_t) -> UIElement {
    AXUIElementCreateApplication(pid)
  }

  public func systemWide() -> UIElement {
    AXUIElementCreateSystemWide()
  }

  public func getPid(element: UIElement, pid: UnsafeMutablePointer<pid_t>) -> AXError {
    AXUIElementGetPid(element, pid)
  }

  public func setMessagingTimeout(element: UIElement, timeoutInSeconds: Float) -> AXError {
    AXUIElementSetMessagingTimeout(element, timeoutInSeconds)
  }

  // MARK: - AXObserver

  public func observerGetTypeID() -> CFTypeID {
    AXObserverGetTypeID()
  }

  public func observerCreate(application: pid_t, outObserver: UnsafeMutablePointer<Observer?>) -> AXError {
    return AXObserverCreate(
      application,
      { observer, element, notification, refcon in
        guard let refcon else { return assertionFailure() }
        let wrapper = Unmanaged<Box<ObserverCallback, ObserverCallbackWithInfo>>.fromOpaque(refcon).takeUnretainedValue()
        wrapper.callback?(observer, element, notification)
      },
      outObserver)
  }

  public func observerCreateWithInfoCallback(application: pid_t, outObserver: UnsafeMutablePointer<Observer?>) -> AXError {
    AXObserverCreateWithInfoCallback(
      application,
      { observer, element, notification, info, refcon in
        guard let refcon else { return assertionFailure() }
        let wrapper = Unmanaged<Box<ObserverCallback, ObserverCallbackWithInfo>>.fromOpaque(refcon).takeUnretainedValue()
        wrapper.callbackWithInfo?(observer, element, notification, info)
      },
      outObserver)
  }

  public func observerAddNotification(observer: Observer, element: UIElement, notification: CFString, refcon: UnsafeMutableRawPointer?) -> AXError {
    return AXObserverAddNotification(observer, element, notification, refcon)
  }

  public func observerRemoveNotification(observer: Observer, element: UIElement, notification: CFString) -> AXError {
    AXObserverRemoveNotification(observer, element, notification)
  }

  public func observerGetRunLoopSource(observer: Observer) -> RunLoopSource {
    AXObserverGetRunLoopSource(observer)
  }

  // MARK: - AXValue
  public func getAXValueTypeID() -> CFTypeID {
    AXValueGetTypeID()
  }

  public func createAXValue(_ theType: AXValueType, _ valuePtr: UnsafeRawPointer) -> UIElementValue? {
    AXValueCreate(theType, valuePtr)
  }

  public func getAXValueType(_ value: UIElementValue) -> AXValueType {
    AXValueGetType(value)
  }

  public func getAXValueValue(_ value: UIElementValue, _ theType: AXValueType, _ valuePtr: UnsafeMutableRawPointer) -> Bool {
    AXValueGetValue(value, theType, valuePtr)
  }

  public func _getWindow(_ axUiElement: UIElement, _ wid: inout CGWindowID) -> AXError {
    _AXUIElementGetWindow(axUiElement, &wid)
  }
}

// https://github.com/lwouis/alt-tab-macos/blob/bd162a9e08743f4fec5d94d1e428c7ea9919dc3f/src/api-wrappers/private-apis/ApplicationServices.HIServices.framework.swift#L4
@_silgen_name("_AXUIElementGetWindow") @discardableResult
func _AXUIElementGetWindow(_ axUiElement: AXUIElement, _ wid: inout CGWindowID) -> AXError

