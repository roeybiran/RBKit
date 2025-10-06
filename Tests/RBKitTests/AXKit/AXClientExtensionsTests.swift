import Foundation
import ApplicationServices
import Testing
@testable import AXKit

@Suite
struct `AXClientExtensions Tests` {

  @Test
  func `isProcessTrusted, with usePrompt == true, preflight == true, should return preflight value without prompt`() async {
    await confirmation { c in
      let sut = AXClientMock()
      sut._isProcessTrusted = {
        c()
        return true
      }
      sut._isProcessTrustedWithOptions = { _ in
        #expect(Bool(false), "Should not call isProcessTrustedWithOptions when preflight is true")
        return false
      }
      
      let result = sut.isProcessTrusted(usePrompt: true)
      #expect(result == true)
    }
  }

  @Test
  func isProcessTrusted_withPromptTrue_preflightFalse_shouldCallPromptAndReturnResult() async {
    await confirmation { c in
      let sut = AXClientMock()
      sut._isProcessTrusted = { false }
      sut._isProcessTrustedWithOptions = { options in
        #expect(options != nil)
        c()
        return true
      }
      
      let result = sut.isProcessTrusted(usePrompt: true)
      #expect(result == true)
    }
  }
  
  @Test
  func isProcessTrusted_withPromptFalse_preflightTrue_shouldReturnPreflightOnly() async {
    await confirmation { c in
      let sut = AXClientMock()
      sut._isProcessTrusted = {
        c()
        return true
      }
      sut._isProcessTrustedWithOptions = { _ in
        #expect(Bool(false), "Should not call isProcessTrustedWithOptions when usePrompt is false")
        return false
      }
      
      let result = sut.isProcessTrusted(usePrompt: false)
      #expect(result == true)
    }
  }
  
  @Test
  func isProcessTrusted_withPromptFalse_preflightFalse_shouldReturnPreflightOnly() async {
    await confirmation { c in
      let sut = AXClientMock()
      sut._isProcessTrusted = {
        c()
        return false
      }
      sut._isProcessTrustedWithOptions = { _ in
        #expect(Bool(false), "Should not call isProcessTrustedWithOptions when usePrompt is false")
        return false
      }
      
      let result = sut.isProcessTrusted(usePrompt: false)
      #expect(result == false)
    }
  }

  @Test
  func attributeNames_withValidElement_shouldReturnNames() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._attributeNames = { receivedElement, names in
        #expect(receivedElement === element)
        names.pointee = ["attr1", "attr2"] as CFArray
        c()
        return .success
      }

      let names = try sut.attributeNames(element: element)
      #expect(names == ["attr1", "attr2"])
    }
  }

  @Test
  func attributeNames_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeNames = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.attributeNames(element: element)
    }
  }

  @Test
  func attributeNames_withCastingFailure_shouldReturnEmptyArray() async throws {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeNames = { _, ptr in
      ptr.pointee = [42] as CFArray
      return .success
    }

    #expect(try sut.attributeNames(element: element) == [])
  }

  @Test
  func attributeValue_withSingleAttribute_shouldReturnValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attribute = Attribute<String>("testAttribute")

      sut._attributeValue = { _, _, value in
        value.pointee = "testValue" as CFTypeRef
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let result: String = try sut.attributeValue(element: element, for: attribute)
      #expect(result == "testValue")
    }
  }

  @Test
  func attributeValue_withSingleAttributeAndError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    let attribute = Attribute<String>("testAttribute")

    sut._attributeValue = { _, _, _ in .failure }
    sut._getAXValueTypeID = { 0 }

    #expect(throws: AXClientError.self) {
      let _: String = try sut.attributeValue(element: element, for: attribute)
    }
  }

  @Test
  func attributeValue_withSingleAttributeAndCastFailure_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    let attribute = Attribute<String>("testAttribute")

    sut._attributeValue = { _, _, value in
      value.pointee = 42 as CFTypeRef
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    #expect(throws: AXClientError.self) {
      let _: String = try sut.attributeValue(element: element, for: attribute)
    }
  }


  @Test
  func getAttributeValueCount_withValidAttribute_shouldReturnCount() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._getAttributeValueCount = { _, _, count in
        count.pointee = 10
        c()
        return .success
      }

      let count = try sut.getAttributeValueCount(element: element, attribute: "testAttribute")
      #expect(count == 10)
    }
  }

  @Test
  func getAttributeValueCount_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getAttributeValueCount = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.getAttributeValueCount(element: element, attribute: "testAttribute")
    }
  }

  @Test
  func attributeValues_withValidParameters_shouldReturnValues() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._attributeValues = { _, _, _, _, values in
        values.pointee = ["value1", "value2"] as CFArray
        c()
        return .success
      }

      let values = try sut.attributeValues(element: element, attribute: "testAttribute", index: 0, maxValues: 5)
      #expect((values as? [String]) == ["value1", "value2"])
    }
  }

  @Test
  func attributeValues_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeValues = { _, _, _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.attributeValues(element: element, attribute: "testAttribute", index: 0, maxValues: 5)
    }
  }

  @Test
  func isAttributeSettable_withValidAttribute_shouldReturnBool() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._isAttributeSettable = { _, _, settable in
        settable.pointee = DarwinBoolean(true)
        c()
        return .success
      }

      let settable = try sut.isAttributeSettable(element: element, attribute: Attribute<String>("testAttribute"))
      #expect(settable == true)
    }
  }

  @Test
  func isAttributeSettable_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._isAttributeSettable = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.isAttributeSettable(element: element, attribute: Attribute<String>("testAttribute"))
    }
  }

  @Test
  func setAttributeValue_withValidValue_shouldSetValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._setAttributeValue = { _, _, _ in
        c()
        return .success
      }

      try sut.setAttributeValue(element: element, attribute: Attribute<String>("testAttribute"), value: "testValue")
    }
  }

  @Test
  func setAttributeValue_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._setAttributeValue = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.setAttributeValue(element: element, attribute: Attribute<String>("testAttribute"), value: "testValue")
    }
  }

  @Test
  func setAttributeValue_withCFRange_shouldEncodeToAXValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let testRange = CFRange(location: 10, length: 20)
      let expectedAXValue = UIElementValueMock(type: .cfRange)
      
      sut._createAXValue = { type, _ in
        #expect(type == .cfRange)
        return expectedAXValue
      }
      
      sut._setAttributeValue = { _, _, value in
        #expect(value === expectedAXValue)
        c()
        return .success
      }

      try sut.setAttributeValue(element: element, attribute: Attribute<CFRange>("testAttribute"), value: testRange)
    }
  }

  @Test
  func setAttributeValue_withCGPoint_shouldEncodeToAXValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let testPoint = CGPoint(x: 100.0, y: 200.0)
      let expectedAXValue = UIElementValueMock(type: .cgPoint)
      
      sut._createAXValue = { type, _ in
        #expect(type == .cgPoint)
        return expectedAXValue
      }
      
      sut._setAttributeValue = { _, _, value in
        #expect(value === expectedAXValue)
        c()
        return .success
      }

      try sut.setAttributeValue(element: element, attribute: Attribute<CGPoint>("testAttribute"), value: testPoint)
    }
  }

  @Test
  func setAttributeValue_withCGRect_shouldEncodeToAXValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let testRect = CGRect(x: 10.0, y: 20.0, width: 300.0, height: 400.0)
      let expectedAXValue = UIElementValueMock(type: .cgRect)
      
      sut._createAXValue = { type, _ in
        #expect(type == .cgRect)
        return expectedAXValue
      }
      
      sut._setAttributeValue = { _, _, value in
        #expect(value === expectedAXValue)
        c()
        return .success
      }

      try sut.setAttributeValue(element: element, attribute: Attribute<CGRect>("testAttribute"), value: testRect)
    }
  }

  @Test
  func setAttributeValue_withCGSize_shouldEncodeToAXValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let testSize = CGSize(width: 500.0, height: 600.0)
      let expectedAXValue = UIElementValueMock(type: .cgSize)
      
      sut._createAXValue = { type, _ in
        #expect(type == .cgSize)
        return expectedAXValue
      }
      
      sut._setAttributeValue = { _, _, value in
        #expect(value === expectedAXValue)
        c()
        return .success
      }

      try sut.setAttributeValue(element: element, attribute: Attribute<CGSize>("testAttribute"), value: testSize)
    }
  }

  @Test
  func actionNames_withValidElement_shouldReturnNames() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._actionNames = { _, names in
        names.pointee = ["action1", "action2"] as CFArray
        c()
        return .success
      }

      let names = try sut.actionNames(element: element)
      #expect(names == ["action1", "action2"])
    }
  }

  @Test
  func actionNames_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._actionNames = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.actionNames(element: element)
    }
  }

  @Test
  func actionDescription_withValidAction_shouldReturnDescription() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let action = Action.press
      sut._actionDescription = { _, _, description in
        description.pointee = "Press Description" as CFString
        c()
        return .success
      }

      let description = try sut.actionDescription(element: element, action: action)
      #expect(description == "Press Description")
    }
  }

  @Test
  func actionDescription_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    let action = Action.press
    sut._actionDescription = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.actionDescription(element: element, action: action)
    }
  }

  @Test
  func performAction_withValidAction_shouldPerformAction() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._performAction = { _, _ in
        c()
        return .success
      }

      try sut.performAction(element: element, action: Action.press)
    }
  }

  @Test
  func performAction_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._performAction = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.performAction(element: element, action: Action.press)
    }
  }

  @Test
  func elementAtPosition_withValidCoordinates_shouldReturnElement() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let application = UIElementMock()
      sut._elementAtPosition = { _, _, _, element in
        element.pointee = UIElementMock()
        c()
        return .success
      }

      let element = try sut.elementAtPosition(application: application, x: 100.0, y: 200.0)
      #expect(element === element)
    }
  }

  @Test
  func elementAtPosition_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let application = UIElementMock()
    sut._elementAtPosition = { _, _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.elementAtPosition(application: application, x: 100.0, y: 200.0)
    }
  }

  @Test
  func getPid_withValidElement_shouldReturnPid() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      sut._getPid = { _, pid in
        pid.pointee = 98765
        c()
        return .success
      }

      let pid = try sut.getPid(element: element)
      #expect(pid == 98765)
    }
  }

  @Test
  func getPid_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getPid = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.getPid(element: element)
    }
  }

  @Test
  func createObserver_withValidPid_shouldReturnObserver() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let pid: pid_t = 12345
      let expectedObserver = ObserverMock(id: "test-observer-123")
      sut._observerCreate = { _, _, outObserver in
        outObserver.pointee = expectedObserver
        c()
        return .success
      }

      let observer = try sut.createObserver(application: pid)
      #expect(observer == expectedObserver)
    }
  }

  @Test
  func createObserver_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    sut._observerCreate = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.createObserver(application: 12345)
    }
  }

  @Test
  func createObserver_withSuccessButNilObserver_shouldThrowUnknown() async {
    let sut = AXClientMock()
    sut._observerCreate = { _, _, outObserver in
      outObserver.pointee = nil  // Success but nil observer
      return .success
    }

    #expect(throws: AXClientError.unknown) {
      try sut.createObserver(application: 12345)
    }
  }

  @Test
  func getWindowID_withValidElement_shouldReturnWindowID() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let expectedWindowID: CGWindowID = 12345
      
      sut._getWindow = { receivedElement, windowIDPtr in
        #expect(receivedElement === element)
        windowIDPtr = expectedWindowID
        c()
        return .success
      }

      let windowID = try sut.getWindowID(of: element)
      #expect(windowID == expectedWindowID)
    }
  }

  @Test
  func getWindowID_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getWindow = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.getWindowID(of: element)
    }
  }

  @Test
  func attributeValue_twoAttributes_multiAttributeValuesFailure_shouldThrow() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    
    sut._attributeValueMultiple = { _, _, _, _ in
      return .failure
    }
    
    #expect(throws: AXClientError.self) {
      try sut.attributeValue(element: element, for: sut.children, sut.parent)
    }
  }

  @Test
  func setAttributeValue_CFRange_createAXValueFailure_shouldFallbackToRawValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let range = CFRange(location: 0, length: 10)
      
      sut._createAXValue = { _, _ in nil }
      sut._setAttributeValue = { receivedElement, attribute, value in
        #expect(receivedElement === element)
        #expect(attribute == AttributeName.selectedTextRange.rawValue as CFString)
        // When createAXValue fails, encode should fall back to raw value
        let receivedRange = value as? CFRange
        #expect(receivedRange?.location == range.location)
        #expect(receivedRange?.length == range.length)
        c()
        return .success
      }
      
      try sut.setAttributeValue(element: element, attribute: Attribute<CFRange>(.selectedTextRange), value: range)
    }
  }

  @Test
  func setAttributeValue_CGPoint_createAXValueFailure_shouldFallbackToRawValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let point = CGPoint(x: 100, y: 200)
      
      sut._createAXValue = { _, _ in nil }
      sut._setAttributeValue = { receivedElement, attribute, value in
        #expect(receivedElement === element)
        #expect(attribute == AttributeName.position.rawValue as CFString)
        // When createAXValue fails, encode should fall back to raw value
        #expect(value as? CGPoint == point)
        c()
        return .success
      }
      
      try sut.setAttributeValue(element: element, attribute: Attribute<CGPoint>(.position), value: point)
    }
  }

  @Test
  func setAttributeValue_CGRect_createAXValueFailure_shouldFallbackToRawValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let rect = CGRect(x: 10, y: 20, width: 100, height: 200)
      
      sut._createAXValue = { _, _ in nil }
      sut._setAttributeValue = { receivedElement, attribute, value in
        #expect(receivedElement === element)
        #expect(attribute == AttributeName.frame.rawValue as CFString)
        // When createAXValue fails, encode should fall back to raw value
        #expect(value as? CGRect == rect)
        c()
        return .success
      }
      
      try sut.setAttributeValue(element: element, attribute: Attribute<CGRect>(.frame), value: rect)
    }
  }

  @Test
  func setAttributeValue_CGSize_createAXValueFailure_shouldFallbackToRawValue() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let size = CGSize(width: 300, height: 400)
      
      sut._createAXValue = { _, _ in nil }
      sut._setAttributeValue = { receivedElement, attribute, value in
        #expect(receivedElement === element)
        #expect(attribute == AttributeName.size.rawValue as CFString)
        // When createAXValue fails, encode should fall back to raw value
        #expect(value as? CGSize == size)
        c()
        return .success
      }
      
      try sut.setAttributeValue(element: element, attribute: Attribute<CGSize>(.size), value: size)
    }
  }

  @Test
  func addNotification_withValidParameters_shouldAddNotification() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let observer = ObserverMock()
      let element = UIElementMock()
      let notification = AXNotification.titleChanged

      sut._observerAddNotification = { _, _, receivedNotification in
        #expect(receivedNotification == notification.rawValue as CFString)
        c()
        return .success
      }

      try sut.addNotification(observer: observer, element: element, notification: notification)
    }
  }

  @Test
  func addNotification_withAXError_shouldThrow() async {
    let sut = AXClientMock()
    let observer = ObserverMock()
    let element = UIElementMock()
    let notification = AXNotification.titleChanged
    sut._observerAddNotification = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.addNotification(observer: observer, element: element, notification: notification)
    }
  }

  @Test
  func attributeValue_with2Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")

      sut._attributeValueMultiple = { _, attributes, _, values in
        let attributeNames = attributes as! [String]
        #expect(attributeNames.contains("attr1"))
        #expect(attributeNames.contains("attr2"))
        values.pointee = ["value1", 42] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2)
      #expect(result1 == "value1")
      #expect(result2 == 42)
    }
  }

  @Test
  func attributeValue_with2Attributes_andCastingFailure_shouldReturnArrayFilledWithNils() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")

      sut._attributeValueMultiple = { _, _, _, _ in
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2)
      #expect(result1 == nil)
      #expect(result2 == nil)
    }
  }

  @Test
  func attributeValue_with3Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")
      let attr3 = Attribute<Bool>("attr3")

      sut._attributeValueMultiple = { _, attributes, _, values in
        let attributeNames = attributes as! [String]
        #expect(attributeNames.count == 3)
        values.pointee = ["value1", 42, true] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2, result3) = try sut.attributeValue(element: element, for: attr1, attr2, attr3)
      #expect(result1 == "value1")
      #expect(result2 == 42)
      #expect(result3 == true)
    }
  }

  @Test
  func attributeValue_with4Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")
      let attr3 = Attribute<Bool>("attr3")
      let attr4 = Attribute<Double>("attr4")

      sut._attributeValueMultiple = { _, attributes, _, values in
        let attributeNames = attributes as! [String]
        #expect(attributeNames.count == 4)
        values.pointee = ["value1", 42, true, 3.14] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2, result3, result4) = try sut.attributeValue(element: element, for: attr1, attr2, attr3, attr4)
      #expect(result1 == "value1")
      #expect(result2 == 42)
      #expect(result3 == true)
      #expect(result4 == 3.14)
    }
  }

  @Test
  func attributeValue_with5Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")
      let attr3 = Attribute<Bool>("attr3")
      let attr4 = Attribute<Double>("attr4")
      let attr5 = Attribute<Float>("attr5")

      sut._attributeValueMultiple = { _, attributes, _, values in
        let attributeNames = attributes as! [String]
        #expect(attributeNames.count == 5)
        values.pointee = ["value1", 42, true, 3.14, Float(2.71)] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2, result3, result4, result5) = try sut.attributeValue(
        element: element,
        for: attr1,
        attr2,
        attr3,
        attr4,
        attr5)
      #expect(result1 == "value1")
      #expect(result2 == 42)
      #expect(result3 == true)
      #expect(result4 == 3.14)
      #expect(result5 == Float(2.71))
    }
  }

  @Test
  func attributeValue_with6Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("a")
      let attr2 = Attribute<String>("b")
      let attr3 = Attribute<String>("c")
      let attr4 = Attribute<String>("d")
      let attr5 = Attribute<String>("e")
      let attr6 = Attribute<String>("f")

      sut._attributeValueMultiple = { _, attributes, _, values in
        let _ = attributes as! [String]
        let v = Array(repeating: "mockUIElement", count: 6)
        values.pointee = v as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2, result3, result4, result5, result6) = try sut.attributeValue(
        element: element,
        for: attr1,
        attr2,
        attr3,
        attr4,
        attr5,
        attr6)
      
      #expect(result1 == "mockUIElement")
      #expect(result2 == "mockUIElement")
      #expect(result3 == "mockUIElement")
      #expect(result4 == "mockUIElement")
      #expect(result5 == "mockUIElement")
      #expect(result6 == "mockUIElement")
    }
  }

  @Test
  func attributeValue_with7Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()

      let attr1 = Attribute<String>("uiElement")

      let attr2 = Attribute<CGPoint>("point")
      let attr3 = Attribute<CGRect>("rect")
      let attr4 = Attribute<CGSize>("size")
      let attr5 = Attribute<CFRange>("range")
      let attr6 = Attribute<AXError>("error")
      let attr7 = Attribute<Int>("illegal")

      let _values = [
        "mockUIElement",
        UIElementValueMock(type: .cgPoint),
        UIElementValueMock(type: .cgRect),
        UIElementValueMock(type: .cgSize),
        UIElementValueMock(type: .cfRange),
        UIElementValueMock(type: .axError),
        UIElementValueMock(type: .illegal)
      ] as [AnyObject]

      sut._attributeValueMultiple = { _, attributes, _, values in
        let attributeNames = attributes as! [String]
        #expect(attributeNames.count == 7)
        values.pointee = _values as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = {
        CFGetTypeID(UIElementValueMock(type: .axError) as AnyObject)
      }
      sut._getAXValueType = { $0.type }
      sut._getAXValueValue = { value, type, ptr in
        switch type {
        case .cgPoint:
          ptr.bindMemory(to: CGPoint.self, capacity: 1).pointee = CGPoint(x: 100, y: 200)
        case .cgRect:
          ptr.bindMemory(to: CGRect.self, capacity: 1).pointee = CGRect(x: 10, y: 20, width: 300, height: 400)
        case .cgSize:
          ptr.bindMemory(to: CGSize.self, capacity: 1).pointee = CGSize(width: 500, height: 600)
        case .cfRange:
          ptr.bindMemory(to: CFRange.self, capacity: 1).pointee = CFRange(location: 0, length: 1)
        case .axError:
          ptr.bindMemory(to: AXError.self, capacity: 1).pointee = .failure
        case .illegal:
          fallthrough
        default:
          break
        }
        return true
      }

      let (result1, result2, result3, result4, result5, result6, result7) = try sut.attributeValue(
        element: element,
        for:
          attr1,
          attr2,
          attr3,
          attr4,
          attr5,
          attr6,
          attr7
      )

      #expect(result1 == "mockUIElement")
      #expect(result2 == CGPoint(x: 100, y: 200))
      #expect(result3 == CGRect(x: 10, y: 20, width: 300, height: 400))
      #expect(result4 == CGSize(width: 500, height: 600))

      let range = try #require(result5)
      let loc = range.location as Int
      let length = range.length as Int
      #expect(loc == 0)
      #expect(length == 1)

      #expect(result6 == .failure)
      #expect(result7 == nil)
    }
  }

  @Test
  func attributeValue_with8Attributes_shouldReturnTuple() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")
      let attr3 = Attribute<Bool>("attr3")
      let attr4 = Attribute<Double>("attr4")
      let attr5 = Attribute<Float>("attr5")
      let attr6 = Attribute<String>("attr6")
      let attr7 = Attribute<Int>("attr7")
      let attr8 = Attribute<Bool>("attr8")

      sut._attributeValueMultiple = { _, attributes, _, values in
        let attributeNames = attributes as! [String]
        #expect(attributeNames.count == 8)
        values.pointee = ["value1", 42, true, 3.14, Float(2.71), "value6", 99, false] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2, result3, result4, result5, result6, result7, result8) = try sut.attributeValue(
        element: element,
        for: attr1,
        attr2,
        attr3,
        attr4,
        attr5,
        attr6,
        attr7,
        attr8)
      #expect(result1 == "value1")
      #expect(result2 == 42)
      #expect(result3 == true)
      #expect(result4 == 3.14)
      #expect(result5 == Float(2.71))
      #expect(result6 == "value6")
      #expect(result7 == 99)
      #expect(result8 == false)
    }
  }

  @Test
  func attributeValue_withStopOnErrorTrue_shouldPassCorrectOptions() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")

      sut._attributeValueMultiple = { _, _, options, values in
        #expect(options == .stopOnError)
        values.pointee = ["value1", 42] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2, stopOnError: true)
      #expect(result1 == "value1")
      #expect(result2 == 42)
    }
  }

  @Test
  func attributeValue_withStopOnErrorFalse_shouldPassCorrectOptions() async throws {
    try await confirmation { c in
      let sut = AXClientMock()
      let element = UIElementMock()
      let attr1 = Attribute<String>("attr1")
      let attr2 = Attribute<Int>("attr2")

      sut._attributeValueMultiple = { _, _, options, values in
        #expect(options == [])
        values.pointee = ["value1", 42] as CFArray
        c()
        return .success
      }
      sut._getAXValueTypeID = { 0 }

      let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2, stopOnError: false)
      #expect(result1 == "value1")
      #expect(result2 == 42)
    }
  }

  // MARK: - observer

  @Test
  func startObserver_withObserver_shouldReturnAsyncStream() async {
    let sut = AXClientMock()
    let observer = ObserverMock()

    sut._observerGetRunLoopSource = { _ in RunLoopSourceMock() }
    sut._addRunLoopSource = { _, _, _ in }
    sut._removeRunLoopSource = { _, _, _ in }

    let stream = await sut.start(observer: observer)

    let task = Task {
      for await _ in stream {
        break
      }
    }
    task.cancel()
  }

  // MARK: - computed vars

  @Test
  func computedAttributeAMPMField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.AMPMField == Attribute<AXClientMock.UIElement>(.AMPMField))
  }

  @Test
  func computedAttributeCancelButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.cancelButton == Attribute<AXClientMock.UIElement>(.cancelButton))
  }

  @Test
  func computedAttributeChildren_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.children == Attribute<[AXClientMock.UIElement]>(.children))
  }

  @Test
  func computedAttributeCloseButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.closeButton == Attribute<AXClientMock.UIElement>(.closeButton))
  }

  @Test
  func computedAttributeColumns_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.columns == Attribute<[AXClientMock.UIElement]>(.columns))
  }

  @Test
  func computedAttributeContents_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.contents == Attribute<[AXClientMock.UIElement]>(.contents))
  }

  @Test
  func computedAttributeDayField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.dayField == Attribute<AXClientMock.UIElement>(.dayField))
  }

  @Test
  func computedAttributeDecrementButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.decrementButton == Attribute<AXClientMock.UIElement>(.decrementButton))
  }

  @Test
  func computedAttributeDefaultButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.defaultButton == Attribute<AXClientMock.UIElement>(.defaultButton))
  }

  @Test
  func computedAttributeDisclosedByRow_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.disclosedByRow == Attribute<AXClientMock.UIElement>(.disclosedByRow))
  }

  @Test
  func computedAttributeDisclosedRows_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.disclosedRows == Attribute<[AXClientMock.UIElement]>(.disclosedRows))
  }

  @Test
  func computedAttributeExtrasMenuBar_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.extrasMenuBar == Attribute<AXClientMock.UIElement>(.extrasMenuBar))
  }

  @Test
  func computedAttributeFocusedUIElement_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.focusedUIElement == Attribute<AXClientMock.UIElement>(.focusedUIElement))
  }

  @Test
  func computedAttributeFocusedWindow_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.focusedWindow == Attribute<AXClientMock.UIElement>(.focusedWindow))
  }

  @Test
  func computedAttributeFullScreenButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.fullScreenButton == Attribute<AXClientMock.UIElement>(.fullScreenButton))
  }

  @Test
  func computedAttributeGrowArea_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.growArea == Attribute<AXClientMock.UIElement>(.growArea))
  }

  @Test
  func computedAttributeHeader_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.header == Attribute<AXClientMock.UIElement>(.header))
  }

  @Test
  func computedAttributeHorizontalScrollBar_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.horizontalScrollBar == Attribute<AXClientMock.UIElement>(.horizontalScrollBar))
  }

  @Test
  func computedAttributeHourField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.hourField == Attribute<AXClientMock.UIElement>(.hourField))
  }

  @Test
  func computedAttributeIncrementButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.incrementButton == Attribute<AXClientMock.UIElement>(.incrementButton))
  }

  @Test
  func computedAttributeIncrementor_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.incrementor == Attribute<AXClientMock.UIElement>(.incrementor))
  }

  @Test
  func computedAttributeLabelUIElements_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.labelUIElements == Attribute<[AXClientMock.UIElement]>(.labelUIElements))
  }

  @Test
  func computedAttributeLinkedUIElements_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.linkedUIElements == Attribute<[AXClientMock.UIElement]>(.linkedUIElements))
  }

  @Test
  func computedAttributeMainWindow_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.mainWindow == Attribute<AXClientMock.UIElement>(.mainWindow))
  }

  @Test
  func computedAttributeMarkerUIElements_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.markerUIElements == Attribute<AXClientMock.UIElement>(.markerUIElements))
  }

  @Test
  func computedAttributeMatteContentUIElement_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.matteContentUIElement == Attribute<AXClientMock.UIElement>(.matteContentUIElement))
  }

  @Test
  func computedAttributeMenuBar_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.menuBar == Attribute<AXClientMock.UIElement>(.menuBar))
  }

  @Test
  func computedAttributeMenuItemPrimaryUIElement_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.menuItemPrimaryUIElement == Attribute<AXClientMock.UIElement>(.menuItemPrimaryUIElement))
  }

  @Test
  func computedAttributeMinimizeButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.minimizeButton == Attribute<AXClientMock.UIElement>(.minimizeButton))
  }

  @Test
  func computedAttributeMinuteField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.minuteField == Attribute<AXClientMock.UIElement>(.minuteField))
  }

  @Test
  func computedAttributeMonthField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.monthField == Attribute<AXClientMock.UIElement>(.monthField))
  }

  @Test
  func computedAttributeNextContents_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.nextContents == Attribute<[AXClientMock.UIElement]>(.nextContents))
  }

  @Test
  func computedAttributeOverflowButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.overflowButton == Attribute<AXClientMock.UIElement>(.overflowButton))
  }

  @Test
  func computedAttributeParent_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.parent == Attribute<AXClientMock.UIElement>(.parent))
  }

  @Test
  func computedAttributePreviousContents_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.previousContents == Attribute<[AXClientMock.UIElement]>(.previousContents))
  }

  @Test
  func computedAttributeProxy_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.proxy == Attribute<AXClientMock.UIElement>(.proxy))
  }

  @Test
  func computedAttributeRows_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.rows == Attribute<[AXClientMock.UIElement]>(.rows))
  }

  @Test
  func computedAttributeSecondField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.secondField == Attribute<AXClientMock.UIElement>(.secondField))
  }

  @Test
  func computedAttributeSelectedChildren_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.selectedChildren == Attribute<[AXClientMock.UIElement]>(.selectedChildren))
  }

  @Test
  func computedAttributeSelectedColumns_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.selectedColumns == Attribute<[AXClientMock.UIElement]>(.selectedColumns))
  }

  @Test
  func computedAttributeSelectedRows_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.selectedRows == Attribute<[AXClientMock.UIElement]>(.selectedRows))
  }

  @Test
  func computedAttributeSharedFocusElements_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.sharedFocusElements == Attribute<[AXClientMock.UIElement]>(.sharedFocusElements))
  }

  @Test
  func computedAttributeSharedTextUIElements_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.sharedTextUIElements == Attribute<[AXClientMock.UIElement]>(.sharedTextUIElements))
  }

  @Test
  func computedAttributeShownMenuUIElement_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.shownMenuUIElement == Attribute<AXClientMock.UIElement>(.shownMenuUIElement))
  }

  @Test
  func computedAttributeSplitters_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.splitters == Attribute<[AXClientMock.UIElement]>(.splitters))
  }

  @Test
  func computedAttributeTabs_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.tabs == Attribute<[AXClientMock.UIElement]>(.tabs))
  }

  @Test
  func computedAttributeTitleUIElement_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.titleUIElement == Attribute<AXClientMock.UIElement>(.titleUIElement))
  }

  @Test
  func computedAttributeToolbarButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.toolbarButton == Attribute<AXClientMock.UIElement>(.toolbarButton))
  }

  @Test
  func computedAttributeTopLevelUIElement_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.topLevelUIElement == Attribute<AXClientMock.UIElement>(.topLevelUIElement))
  }

  @Test
  func computedAttributeVerticalScrollBar_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.verticalScrollBar == Attribute<AXClientMock.UIElement>(.verticalScrollBar))
  }

  @Test
  func computedAttributeVisibleChildren_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.visibleChildren == Attribute<[AXClientMock.UIElement]>(.visibleChildren))
  }

  @Test
  func computedAttributeVisibleColumns_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.visibleColumns == Attribute<[AXClientMock.UIElement]>(.visibleColumns))
  }

  @Test
  func computedAttributeVisibleRows_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.visibleRows == Attribute<[AXClientMock.UIElement]>(.visibleRows))
  }

  @Test
  func computedAttributeWindow_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.window == Attribute<AXClientMock.UIElement>(.window))
  }

  @Test
  func computedAttributeWindows_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.windows == Attribute<[AXClientMock.UIElement]>(.windows))
  }

  @Test
  func computedAttributeYearField_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.yearField == Attribute<AXClientMock.UIElement>(.yearField))
  }

  @Test
  func computedAttributeZoomButton_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.zoomButton == Attribute<AXClientMock.UIElement>(.zoomButton))
  }

  @Test
  func computedAttributeFocusedApplication_always_shouldReturnCorrectAttribute() {
    let sut = AXClientMock()
    #expect(sut.focusedApplication == Attribute<AXClientMock.UIElement>(.focusedApplication))
  }
}

