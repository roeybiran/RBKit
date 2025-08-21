import ApplicationServices

// MARK: - AXClientLive

public final class AXClientLive: AXClient {

  // MARK: Public

  public init() { }

  public typealias UIElement = AXUIElement
  public typealias UIElementValue = AXValue
  public typealias Observer = AXObserver
  public typealias RunLoopSource = CFRunLoopSource

  public let box: SpecializedBox = .init()

  // MARK: - Process Trust
  public func isProcessTrustedWithOptions(_ options: CFDictionary?) -> Bool {
    AXIsProcessTrustedWithOptions(options)
  }

  public func isProcessTrusted() -> Bool {
    AXIsProcessTrusted()
  }

  // MARK: - AXUIElement
  public func getTypeID() -> CFTypeID {
    AXUIElementGetTypeID()
  }

  public func attributeNames(element: AXUIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError {
    AXUIElementCopyAttributeNames(element, names)
  }

  public func attributeValue(element: AXUIElement, attribute: CFString, value: UnsafeMutablePointer<CFTypeRef?>) -> AXError {
    AXUIElementCopyAttributeValue(element, attribute, value)
  }

  public func getAttributeValueCount(element: AXUIElement, attribute: CFString, count: UnsafeMutablePointer<CFIndex>) -> AXError {
    AXUIElementGetAttributeValueCount(element, attribute, count)
  }

  public func attributeValues(
    element: AXUIElement,
    attribute: CFString,
    index: CFIndex,
    maxValues: CFIndex,
    values: UnsafeMutablePointer<CFArray?>)
    -> AXError
  {
    AXUIElementCopyAttributeValues(element, attribute, index, maxValues, values)
  }

  public func isAttributeSettable(
    element: AXUIElement,
    attribute: CFString,
    settable: UnsafeMutablePointer<DarwinBoolean>)
    -> AXError
  {
    AXUIElementIsAttributeSettable(element, attribute, settable)
  }

  public func setAttributeValue(element: AXUIElement, attribute: CFString, value: CFTypeRef) -> AXError {
    AXUIElementSetAttributeValue(element, attribute, value)
  }

  public func multipleAttributeValues(
    element: AXUIElement,
    attributes: CFArray,
    options: AXCopyMultipleAttributeOptions,
    values: UnsafeMutablePointer<CFArray?>)
    -> AXError
  {
    AXUIElementCopyMultipleAttributeValues(element, attributes, options, values)
  }

  // func parameterizedAttributeNames(element: AXUIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError { fatalError("TODO") }
  // func parameterizedAttributeValue(element: AXUIElement, parameterizedAttribute: CFString, parameter: CFTypeRef, result: UnsafeMutablePointer<CFTypeRef?>) -> AXError { fatalError("TODO") }

  public func actionNames(element: AXUIElement, names: UnsafeMutablePointer<CFArray?>) -> AXError {
    AXUIElementCopyActionNames(element, names)
  }

  public func actionDescription(element: AXUIElement, action: CFString, description: UnsafeMutablePointer<CFString?>) -> AXError {
    AXUIElementCopyActionDescription(element, action, description)
  }

  public func performAction(element: AXUIElement, action: CFString) -> AXError {
    AXUIElementPerformAction(element, action)
  }

  public func elementAtPosition(
    application: AXUIElement,
    x: Float,
    y: Float,
    element: UnsafeMutablePointer<AXUIElement?>)
    -> AXError
  {
    AXUIElementCopyElementAtPosition(application, x, y, element)
  }

  public func application(pid: pid_t) -> AXUIElement {
    AXUIElementCreateApplication(pid)
  }

  public func systemWide() -> AXUIElement {
    AXUIElementCreateSystemWide()
  }

  public func getPid(element: AXUIElement, pid: UnsafeMutablePointer<pid_t>) -> AXError {
    AXUIElementGetPid(element, pid)
  }

  public func setMessagingTimeout(element: AXUIElement, timeoutInSeconds: Float) -> AXError {
    AXUIElementSetMessagingTimeout(element, timeoutInSeconds)
  }

  // MARK: - AXObserver

  public func observerGetTypeID() -> CFTypeID {
    AXObserverGetTypeID()
  }

  public func observerCreate(application: pid_t, outObserver: UnsafeMutablePointer<AXObserver?>) -> AXError {
    return AXObserverCreate(
      application,
      { observer, element, notification, refcon in
        guard let refcon else { return assertionFailure() }
        let wrapper = Unmanaged<SpecializedBox>.fromOpaque(refcon).takeUnretainedValue()
        wrapper.callback?(observer, element, notification)
      },
      outObserver)
  }

  public func observerCreateWithInfoCallback(application: pid_t, outObserver: UnsafeMutablePointer<AXObserver?>) -> AXError {
    AXObserverCreateWithInfoCallback(
      application,
      { observer, element, notification, info, refcon in
        guard let refcon else { return assertionFailure() }
        let wrapper = Unmanaged<SpecializedBox>.fromOpaque(refcon).takeUnretainedValue()
        wrapper.callbackWithInfo?(observer, element, notification, info)
      },
      outObserver)
  }

  public func observerAddNotification(observer: AXObserver, element: AXUIElement, notification: CFString, refcon: UnsafeMutableRawPointer?) -> AXError {
    return AXObserverAddNotification(observer, element, notification, refcon)
  }

  public func observerRemoveNotification(observer: AXObserver, element: AXUIElement, notification: CFString) -> AXError {
    AXObserverRemoveNotification(observer, element, notification)
  }

  public func observerGetRunLoopSource(observer: AXObserver) -> CFRunLoopSource {
    AXObserverGetRunLoopSource(observer)
  }

  // MARK: - AXValue
  public func getAXValueTypeID() -> CFTypeID {
    AXValueGetTypeID()
  }

  public func createAXValue(_ theType: AXValueType, _ valuePtr: UnsafeRawPointer) -> AXValue? {
    AXValueCreate(theType, valuePtr)
  }

  public func getAXValueType(_ value: AXValue) -> AXValueType {
    AXValueGetType(value)
  }

  public func getAXValueValue(_ value: AXValue, _ theType: AXValueType, _ valuePtr: UnsafeMutableRawPointer) -> Bool {
    AXValueGetValue(value, theType, valuePtr)
  }

  // MARK: - CFRunLoopSource
  public func addRunLoopSource(runLoop: CFRunLoop!, source: CFRunLoopSource!, mode: CFRunLoopMode!) {
    CFRunLoopAddSource(runLoop, source, mode)
  }

  public func removeRunLoopSource(runLoop: CFRunLoop!, source: CFRunLoopSource!, mode: CFRunLoopMode!) {
    CFRunLoopRemoveSource(runLoop, source, mode)
  }

  public func _getWindow(_ axUiElement: AXUIElement, _ wid: inout CGWindowID) -> AXError {
    _AXUIElementGetWindow(axUiElement, &wid)
  }
}

// https://github.com/lwouis/alt-tab-macos/blob/bd162a9e08743f4fec5d94d1e428c7ea9919dc3f/src/api-wrappers/private-apis/ApplicationServices.HIServices.framework.swift#L4
@_silgen_name("_AXUIElementGetWindow") @discardableResult
func _AXUIElementGetWindow(_ axUiElement: AXUIElement, _ wid: inout CGWindowID) -> AXError

