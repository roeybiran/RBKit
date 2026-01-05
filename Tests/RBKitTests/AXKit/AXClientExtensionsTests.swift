import Foundation
import ApplicationServices
import Testing
@testable import AXKit

@Suite
struct `AXClientExtensions Tests` {

  @Test
  func `isProcessTrusted, with usePrompt == true, preflight == true, should return preflight value without prompt`() async {
    nonisolated(unsafe) var didCall = false
      let sut = AXClientMock()
      sut._isProcessTrusted = {
        didCall = true
        return true
      }
      sut._isProcessTrustedWithOptions = { _ in
        #expect(Bool(false), "Should not call isProcessTrustedWithOptions when preflight is true")
        return false
      }
      
      let result = sut.isProcessTrusted(usePrompt: true)
      #expect(result == true)
      #expect(didCall == true)
  }

  @Test
  func `isProcessTrusted, with usePrompt == true, preflight == false, should call prompt and return result`() async {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    sut._isProcessTrusted = { false }
    sut._isProcessTrustedWithOptions = { options in
      #expect(options != nil)
      didCall = true
      return true
    }
    
    let result = sut.isProcessTrusted(usePrompt: true)
    #expect(result == true)
    #expect(didCall == true)
  }
  
  @Test
  func `isProcessTrusted, with usePrompt == false, preflight == true, should return preflight only`() async {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    sut._isProcessTrusted = {
      didCall = true
      return true
    }
    sut._isProcessTrustedWithOptions = { _ in
      #expect(Bool(false), "Should not call isProcessTrustedWithOptions when usePrompt is false")
      return false
    }
    
    let result = sut.isProcessTrusted(usePrompt: false)
    #expect(result == true)
    #expect(didCall == true)
  }
  
  @Test
  func `isProcessTrusted, with usePrompt == false, preflight == false, should return preflight only`() async {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    sut._isProcessTrusted = {
      didCall = true
      return false
    }
    sut._isProcessTrustedWithOptions = { _ in
      #expect(Bool(false), "Should not call isProcessTrustedWithOptions when usePrompt is false")
      return false
    }
    
    let result = sut.isProcessTrusted(usePrompt: false)
    #expect(result == false)
    #expect(didCall == true)
  }

  @Test
  func `attributeNames, with valid element, should return names`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeNames = { receivedElement, names in
      #expect(receivedElement === element)
      names.pointee = ["attr1", "attr2"] as CFArray
      didCall = true
      return .success
    }

    let names = try sut.attributeNames(element: element)
    #expect(names == ["attr1", "attr2"])
    #expect(didCall == true)
  }

  @Test
  func `attributeNames, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeNames = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.attributeNames(element: element)
    }
  }

  @Test
  func `attributeNames, with casting failure, should return empty array`() async throws {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeNames = { _, ptr in
      ptr.pointee = [42] as CFArray
      return .success
    }

    #expect(try sut.attributeNames(element: element) == [])
  }

  @Test
  func `attributeValue, with single attribute, should return value`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let attribute = Attribute<String>("testAttribute")

    sut._attributeValue = { _, _, value in
      value.pointee = "testValue" as CFTypeRef
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let result: String = try sut.attributeValue(element: element, for: attribute)
    #expect(result == "testValue")
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with single attribute and error, should throw`() async {
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
  func `attributeValue, with single attribute and cast failure, should throw`() async {
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
  func `getAttributeValueCount, with valid attribute, should return count`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getAttributeValueCount = { _, _, count in
      count.pointee = 10
      didCall = true
      return .success
    }

    let count = try sut.getAttributeValueCount(element: element, attribute: "testAttribute")
    #expect(count == 10)
    #expect(didCall == true)
  }

  @Test
  func `getAttributeValueCount, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getAttributeValueCount = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.getAttributeValueCount(element: element, attribute: "testAttribute")
    }
  }

  @Test
  func `attributeValues, with valid parameters, should return values`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeValues = { _, _, _, _, values in
      values.pointee = ["value1", "value2"] as CFArray
      didCall = true
      return .success
    }

    let values = try sut.attributeValues(element: element, attribute: "testAttribute", index: 0, maxValues: 5)
    #expect((values as? [String]) == ["value1", "value2"])
    #expect(didCall == true)
  }

  @Test
  func `attributeValues, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._attributeValues = { _, _, _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.attributeValues(element: element, attribute: "testAttribute", index: 0, maxValues: 5)
    }
  }

  @Test
  func `isAttributeSettable, with valid attribute, should return bool`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._isAttributeSettable = { _, _, settable in
      settable.pointee = DarwinBoolean(true)
      didCall = true
      return .success
    }

    let settable = try sut.isAttributeSettable(element: element, attribute: Attribute<String>("testAttribute"))
    #expect(settable == true)
    #expect(didCall == true)
  }

  @Test
  func `isAttributeSettable, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._isAttributeSettable = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.isAttributeSettable(element: element, attribute: Attribute<String>("testAttribute"))
    }
  }

  @Test
  func `setAttributeValue, with valid value, should set value`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._setAttributeValue = { _, _, _ in
      didCall = true
      return .success
    }

    try sut.setAttributeValue(element: element, attribute: Attribute<String>("testAttribute"), value: "testValue")
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._setAttributeValue = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.setAttributeValue(element: element, attribute: Attribute<String>("testAttribute"), value: "testValue")
    }
  }

  @Test
  func `setAttributeValue, with CFRange, should encode to AXValue`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
      return .success
    }

    try sut.setAttributeValue(element: element, attribute: Attribute<CFRange>("testAttribute"), value: testRange)
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, with CGPoint, should encode to AXValue`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
      return .success
    }

    try sut.setAttributeValue(element: element, attribute: Attribute<CGPoint>("testAttribute"), value: testPoint)
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, with CGRect, should encode to AXValue`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
      return .success
    }

    try sut.setAttributeValue(element: element, attribute: Attribute<CGRect>("testAttribute"), value: testRect)
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, with CGSize, should encode to AXValue`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
      return .success
    }

    try sut.setAttributeValue(element: element, attribute: Attribute<CGSize>("testAttribute"), value: testSize)
    #expect(didCall == true)
  }

  @Test
  func `actionNames, with valid element, should return names`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._actionNames = { _, names in
      names.pointee = ["action1", "action2"] as CFArray
      didCall = true
      return .success
    }

    let names = try sut.actionNames(element: element)
    #expect(names == ["action1", "action2"])
    #expect(didCall == true)
  }

  @Test
  func `actionNames, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._actionNames = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.actionNames(element: element)
    }
  }

  @Test
  func `actionDescription, with valid action, should return description`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let action = Action.press
    sut._actionDescription = { _, _, description in
      description.pointee = "Press Description" as CFString
      didCall = true
      return .success
    }

    let description = try sut.actionDescription(element: element, action: action)
    #expect(description == "Press Description")
    #expect(didCall == true)
  }

  @Test
  func `actionDescription, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    let action = Action.press
    sut._actionDescription = { _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.actionDescription(element: element, action: action)
    }
  }

  @Test
  func `performAction, with valid action, should perform action`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._performAction = { _, _ in
      didCall = true
      return .success
    }

    try sut.performAction(element: element, action: Action.press)
    #expect(didCall == true)
  }

  @Test
  func `performAction, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._performAction = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.performAction(element: element, action: Action.press)
    }
  }

  @Test
  func `elementAtPosition, with valid coordinates, should return element`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let application = UIElementMock()
    sut._elementAtPosition = { _, _, _, element in
      element.pointee = UIElementMock()
      didCall = true
      return .success
    }

    let element = try sut.elementAtPosition(application: application, x: 100.0, y: 200.0)
    #expect(element != nil)
    #expect(didCall == true)
  }

  @Test
  func `elementAtPosition, with AXError, should throw`() async {
    let sut = AXClientMock()
    let application = UIElementMock()
    sut._elementAtPosition = { _, _, _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.elementAtPosition(application: application, x: 100.0, y: 200.0)
    }
  }

  @Test
  func `getPid, with valid element, should return pid`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getPid = { _, pid in
      pid.pointee = 98765
      didCall = true
      return .success
    }

    let pid = try sut.getPid(element: element)
    #expect(pid == 98765)
    #expect(didCall == true)
  }

  @Test
  func `getPid, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getPid = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.getPid(element: element)
    }
  }


  @Test
  func `getWindowID, with valid element, should return window ID`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let expectedWindowID: CGWindowID = 12345
    
    sut._getWindow = { receivedElement, windowIDPtr in
      #expect(receivedElement === element)
      windowIDPtr = expectedWindowID
      didCall = true
      return .success
    }

    let windowID = try sut.getWindowID(of: element)
    #expect(windowID == expectedWindowID)
    #expect(didCall == true)
  }

  @Test
  func `getWindowID, with AXError, should throw`() async {
    let sut = AXClientMock()
    let element = UIElementMock()
    sut._getWindow = { _, _ in .failure }

    #expect(throws: AXClientError.self) {
      try sut.getWindowID(of: element)
    }
  }

  @Test
  func `attributeValue, two attributes, multi attribute values failure, should throw`() async {
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
  func `setAttributeValue, CFRange, create AXValue failure, should fallback to raw value`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
      return .success
    }
    
    try sut.setAttributeValue(element: element, attribute: Attribute<CFRange>(.selectedTextRange), value: range)
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, CGPoint, create AXValue failure, should fallback to raw value`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let point = CGPoint(x: 100, y: 200)
    
    sut._createAXValue = { _, _ in nil }
    sut._setAttributeValue = { receivedElement, attribute, value in
      #expect(receivedElement === element)
      #expect(attribute == AttributeName.position.rawValue as CFString)
      // When createAXValue fails, encode should fall back to raw value
      #expect(value as? CGPoint == point)
      didCall = true
      return .success
    }
    
    try sut.setAttributeValue(element: element, attribute: Attribute<CGPoint>(.position), value: point)
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, CGRect, create AXValue failure, should fallback to raw value`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let rect = CGRect(x: 10, y: 20, width: 100, height: 200)
    
    sut._createAXValue = { _, _ in nil }
    sut._setAttributeValue = { receivedElement, attribute, value in
      #expect(receivedElement === element)
      #expect(attribute == AttributeName.frame.rawValue as CFString)
      // When createAXValue fails, encode should fall back to raw value
      #expect(value as? CGRect == rect)
      didCall = true
      return .success
    }
    
    try sut.setAttributeValue(element: element, attribute: Attribute<CGRect>(.frame), value: rect)
    #expect(didCall == true)
  }

  @Test
  func `setAttributeValue, CGSize, create AXValue failure, should fallback to raw value`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let size = CGSize(width: 300, height: 400)
    
    sut._createAXValue = { _, _ in nil }
    sut._setAttributeValue = { receivedElement, attribute, value in
      #expect(receivedElement === element)
      #expect(attribute == AttributeName.size.rawValue as CFString)
      // When createAXValue fails, encode should fall back to raw value
      #expect(value as? CGSize == size)
      didCall = true
      return .success
    }
    
    try sut.setAttributeValue(element: element, attribute: Attribute<CGSize>(.size), value: size)
    #expect(didCall == true)
  }


  @Test
  func `attributeValue, with 2 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let attr1 = Attribute<String>("attr1")
    let attr2 = Attribute<Int>("attr2")

    sut._attributeValueMultiple = { _, attributes, _, values in
      let attributeNames = attributes as! [String]
      #expect(attributeNames.contains("attr1"))
      #expect(attributeNames.contains("attr2"))
      values.pointee = ["value1", 42] as CFArray
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2)
    #expect(result1 == "value1")
    #expect(result2 == 42)
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 2 attributes and casting failure, should return array filled with nils`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let attr1 = Attribute<String>("attr1")
    let attr2 = Attribute<Int>("attr2")

    sut._attributeValueMultiple = { _, _, _, _ in
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2)
    #expect(result1 == nil)
    #expect(result2 == nil)
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 3 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let attr1 = Attribute<String>("attr1")
    let attr2 = Attribute<Int>("attr2")
    let attr3 = Attribute<Bool>("attr3")

    sut._attributeValueMultiple = { _, attributes, _, values in
      let attributeNames = attributes as! [String]
      #expect(attributeNames.count == 3)
      values.pointee = ["value1", 42, true] as CFArray
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let (result1, result2, result3) = try sut.attributeValue(element: element, for: attr1, attr2, attr3)
    #expect(result1 == "value1")
    #expect(result2 == 42)
    #expect(result3 == true)
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 4 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let (result1, result2, result3, result4) = try sut.attributeValue(element: element, for: attr1, attr2, attr3, attr4)
    #expect(result1 == "value1")
    #expect(result2 == 42)
    #expect(result3 == true)
    #expect(result4 == 3.14)
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 5 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
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
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 6 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
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
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 7 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
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
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with 8 attributes, should return tuple`() async throws {
    nonisolated(unsafe) var didCall = false
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
      didCall = true
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
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with stopOnError == true, should pass correct options`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let attr1 = Attribute<String>("attr1")
    let attr2 = Attribute<Int>("attr2")

    sut._attributeValueMultiple = { _, _, options, values in
      #expect(options == .stopOnError)
      values.pointee = ["value1", 42] as CFArray
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2, stopOnError: true)
    #expect(result1 == "value1")
    #expect(result2 == 42)
    #expect(didCall == true)
  }

  @Test
  func `attributeValue, with stopOnError == false, should pass correct options`() async throws {
    nonisolated(unsafe) var didCall = false
    let sut = AXClientMock()
    let element = UIElementMock()
    let attr1 = Attribute<String>("attr1")
    let attr2 = Attribute<Int>("attr2")

    sut._attributeValueMultiple = { _, _, options, values in
      #expect(options == [])
      values.pointee = ["value1", 42] as CFArray
      didCall = true
      return .success
    }
    sut._getAXValueTypeID = { 0 }

    let (result1, result2) = try sut.attributeValue(element: element, for: attr1, attr2, stopOnError: false)
    #expect(result1 == "value1")
    #expect(result2 == 42)
    #expect(didCall == true)
  }


  // MARK: - computed vars

  @Test
  func `computedAttribute AMPMField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.AMPMField == Attribute<AXClientMock.UIElement>(.AMPMField))
  }

  @Test
  func `computedAttribute cancelButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.cancelButton == Attribute<AXClientMock.UIElement>(.cancelButton))
  }

  @Test
  func `computedAttribute children, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.children == Attribute<[AXClientMock.UIElement]>(.children))
  }

  @Test
  func `computedAttribute closeButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.closeButton == Attribute<AXClientMock.UIElement>(.closeButton))
  }

  @Test
  func `computedAttribute columns, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.columns == Attribute<[AXClientMock.UIElement]>(.columns))
  }

  @Test
  func `computedAttribute contents, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.contents == Attribute<[AXClientMock.UIElement]>(.contents))
  }

  @Test
  func `computedAttribute dayField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.dayField == Attribute<AXClientMock.UIElement>(.dayField))
  }

  @Test
  func `computedAttribute decrementButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.decrementButton == Attribute<AXClientMock.UIElement>(.decrementButton))
  }

  @Test
  func `computedAttribute defaultButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.defaultButton == Attribute<AXClientMock.UIElement>(.defaultButton))
  }

  @Test
  func `computedAttribute disclosedByRow, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.disclosedByRow == Attribute<AXClientMock.UIElement>(.disclosedByRow))
  }

  @Test
  func `computedAttribute disclosedRows, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.disclosedRows == Attribute<[AXClientMock.UIElement]>(.disclosedRows))
  }

  @Test
  func `computedAttribute extrasMenuBar, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.extrasMenuBar == Attribute<AXClientMock.UIElement>(.extrasMenuBar))
  }

  @Test
  func `computedAttribute focusedUIElement, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.focusedUIElement == Attribute<AXClientMock.UIElement>(.focusedUIElement))
  }

  @Test
  func `computedAttribute focusedWindow, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.focusedWindow == Attribute<AXClientMock.UIElement>(.focusedWindow))
  }

  @Test
  func `computedAttribute fullScreenButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.fullScreenButton == Attribute<AXClientMock.UIElement>(.fullScreenButton))
  }

  @Test
  func `computedAttribute growArea, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.growArea == Attribute<AXClientMock.UIElement>(.growArea))
  }

  @Test
  func `computedAttribute header, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.header == Attribute<AXClientMock.UIElement>(.header))
  }

  @Test
  func `computedAttribute horizontalScrollBar, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.horizontalScrollBar == Attribute<AXClientMock.UIElement>(.horizontalScrollBar))
  }

  @Test
  func `computedAttribute hourField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.hourField == Attribute<AXClientMock.UIElement>(.hourField))
  }

  @Test
  func `computedAttribute incrementButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.incrementButton == Attribute<AXClientMock.UIElement>(.incrementButton))
  }

  @Test
  func `computedAttribute incrementor, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.incrementor == Attribute<AXClientMock.UIElement>(.incrementor))
  }

  @Test
  func `computedAttribute labelUIElements, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.labelUIElements == Attribute<[AXClientMock.UIElement]>(.labelUIElements))
  }

  @Test
  func `computedAttribute linkedUIElements, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.linkedUIElements == Attribute<[AXClientMock.UIElement]>(.linkedUIElements))
  }

  @Test
  func `computedAttribute mainWindow, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.mainWindow == Attribute<AXClientMock.UIElement>(.mainWindow))
  }

  @Test
  func `computedAttribute markerUIElements, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.markerUIElements == Attribute<AXClientMock.UIElement>(.markerUIElements))
  }

  @Test
  func `computedAttribute matteContentUIElement, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.matteContentUIElement == Attribute<AXClientMock.UIElement>(.matteContentUIElement))
  }

  @Test
  func `computedAttribute menuBar, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.menuBar == Attribute<AXClientMock.UIElement>(.menuBar))
  }

  @Test
  func `computedAttribute menuItemPrimaryUIElement, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.menuItemPrimaryUIElement == Attribute<AXClientMock.UIElement>(.menuItemPrimaryUIElement))
  }

  @Test
  func `computedAttribute minimizeButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.minimizeButton == Attribute<AXClientMock.UIElement>(.minimizeButton))
  }

  @Test
  func `computedAttribute minuteField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.minuteField == Attribute<AXClientMock.UIElement>(.minuteField))
  }

  @Test
  func `computedAttribute monthField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.monthField == Attribute<AXClientMock.UIElement>(.monthField))
  }

  @Test
  func `computedAttribute nextContents, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.nextContents == Attribute<[AXClientMock.UIElement]>(.nextContents))
  }

  @Test
  func `computedAttribute overflowButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.overflowButton == Attribute<AXClientMock.UIElement>(.overflowButton))
  }

  @Test
  func `computedAttribute parent, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.parent == Attribute<AXClientMock.UIElement>(.parent))
  }

  @Test
  func `computedAttribute previousContents, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.previousContents == Attribute<[AXClientMock.UIElement]>(.previousContents))
  }

  @Test
  func `computedAttribute proxy, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.proxy == Attribute<AXClientMock.UIElement>(.proxy))
  }

  @Test
  func `computedAttribute rows, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.rows == Attribute<[AXClientMock.UIElement]>(.rows))
  }

  @Test
  func `computedAttribute secondField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.secondField == Attribute<AXClientMock.UIElement>(.secondField))
  }

  @Test
  func `computedAttribute selectedChildren, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.selectedChildren == Attribute<[AXClientMock.UIElement]>(.selectedChildren))
  }

  @Test
  func `computedAttribute selectedColumns, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.selectedColumns == Attribute<[AXClientMock.UIElement]>(.selectedColumns))
  }

  @Test
  func `computedAttribute selectedRows, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.selectedRows == Attribute<[AXClientMock.UIElement]>(.selectedRows))
  }

  @Test
  func `computedAttribute sharedFocusElements, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.sharedFocusElements == Attribute<[AXClientMock.UIElement]>(.sharedFocusElements))
  }

  @Test
  func `computedAttribute sharedTextUIElements, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.sharedTextUIElements == Attribute<[AXClientMock.UIElement]>(.sharedTextUIElements))
  }

  @Test
  func `computedAttribute shownMenuUIElement, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.shownMenuUIElement == Attribute<AXClientMock.UIElement>(.shownMenuUIElement))
  }

  @Test
  func `computedAttribute splitters, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.splitters == Attribute<[AXClientMock.UIElement]>(.splitters))
  }

  @Test
  func `computedAttribute tabs, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.tabs == Attribute<[AXClientMock.UIElement]>(.tabs))
  }

  @Test
  func `computedAttribute titleUIElement, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.titleUIElement == Attribute<AXClientMock.UIElement>(.titleUIElement))
  }

  @Test
  func `computedAttribute toolbarButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.toolbarButton == Attribute<AXClientMock.UIElement>(.toolbarButton))
  }

  @Test
  func `computedAttribute topLevelUIElement, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.topLevelUIElement == Attribute<AXClientMock.UIElement>(.topLevelUIElement))
  }

  @Test
  func `computedAttribute verticalScrollBar, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.verticalScrollBar == Attribute<AXClientMock.UIElement>(.verticalScrollBar))
  }

  @Test
  func `computedAttribute visibleChildren, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.visibleChildren == Attribute<[AXClientMock.UIElement]>(.visibleChildren))
  }

  @Test
  func `computedAttribute visibleColumns, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.visibleColumns == Attribute<[AXClientMock.UIElement]>(.visibleColumns))
  }

  @Test
  func `computedAttribute visibleRows, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.visibleRows == Attribute<[AXClientMock.UIElement]>(.visibleRows))
  }

  @Test
  func `computedAttribute window, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.window == Attribute<AXClientMock.UIElement>(.window))
  }

  @Test
  func `computedAttribute windows, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.windows == Attribute<[AXClientMock.UIElement]>(.windows))
  }

  @Test
  func `computedAttribute yearField, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.yearField == Attribute<AXClientMock.UIElement>(.yearField))
  }

  @Test
  func `computedAttribute zoomButton, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.zoomButton == Attribute<AXClientMock.UIElement>(.zoomButton))
  }

  @Test
  func `computedAttribute focusedApplication, always, should return correct attribute`() {
    let sut = AXClientMock()
    #expect(sut.focusedApplication == Attribute<AXClientMock.UIElement>(.focusedApplication))
  }
}

