import AppKit

// MARK: - NSEventMock

#if DEBUG
  extension NSEvent {

    open class Mock: NSEvent {

      // MARK: Open

      override open class var isSwipeTrackingFromScrollEventsEnabled: Bool {
        _isSwipeTrackingFromScrollEventsEnabled
      }
      override open class var mouseLocation: NSPoint { _mouseLocation }
      override open class var modifierFlags: NSEvent.ModifierFlags { _modifierFlags }
      override open class var pressedMouseButtons: Int { _pressedMouseButtons }
      override open class var doubleClickInterval: TimeInterval { _doubleClickInterval }
      override open class var keyRepeatDelay: TimeInterval { _keyRepeatDelay }
      override open class var keyRepeatInterval: TimeInterval { _keyRepeatInterval }

      override open var type: NSEvent.EventType { _type }
      override open var modifierFlags: NSEvent.ModifierFlags { _modifierFlags }
      override open var timestamp: TimeInterval { _timestamp }
      weak override open var window: NSWindow? { _window }
      override open var windowNumber: Int { _windowNumber }
      override open var context: NSGraphicsContext? { _context }
      override open var clickCount: Int { _clickCount }
      override open var buttonNumber: Int { _buttonNumber }
      override open var eventNumber: Int { _eventNumber }
      override open var pressure: Float { _pressure }
      override open var locationInWindow: NSPoint { _locationInWindow }
      override open var deltaX: CGFloat { _deltaX }
      override open var deltaY: CGFloat { _deltaY }
      override open var deltaZ: CGFloat { _deltaZ }
      override open var hasPreciseScrollingDeltas: Bool { _hasPreciseScrollingDeltas }
      override open var scrollingDeltaX: CGFloat { _scrollingDeltaX }
      override open var scrollingDeltaY: CGFloat { _scrollingDeltaY }
      override open var momentumPhase: NSEvent.Phase { _momentumPhase }
      override open var isDirectionInvertedFromDevice: Bool { _isDirectionInvertedFromDevice }
      override open var characters: String? { _characters }
      override open var charactersIgnoringModifiers: String? { _charactersIgnoringModifiers }
      override open var isARepeat: Bool { _isARepeat }
      override open var keyCode: UInt16 { _keyCode }
      override open var trackingNumber: Int { _trackingNumber }
      override open var userData: UnsafeMutableRawPointer? { _userData }
      override open var trackingArea: NSTrackingArea? { _trackingArea }
      override open var subtype: NSEvent.EventSubtype { _subtype }
      override open var data1: Int { _data1 }
      override open var data2: Int { _data2 }
      override open var cgEvent: CGEvent? { _cgEvent }
      // override open class var isMouseCoalescingEnabled: Bool { _isMouseCoalescingEnabled }

      override open var magnification: CGFloat { _magnification }
      override open var deviceID: Int { _deviceID }
      override open var rotation: Float { _rotation }
      override open var absoluteX: Int { _absoluteX }
      override open var absoluteY: Int { _absoluteY }
      override open var absoluteZ: Int { _absoluteZ }
      override open var buttonMask: NSEvent.ButtonMask { _buttonMask }
      override open var tilt: NSPoint { _tilt }
      override open var tangentialPressure: Float { _tangentialPressure }
      override open var vendorDefined: Any { _vendorDefined }
      override open var vendorID: Int { _vendorID }
      override open var tabletID: Int { _tabletID }
      override open var pointingDeviceID: Int { _pointingDeviceID }
      override open var systemTabletID: Int { _systemTabletID }
      override open var vendorPointingDeviceType: Int { _vendorPointingDeviceType }
      override open var pointingDeviceSerialNumber: Int { _pointingDeviceSerialNumber }
      override open var uniqueID: UInt64 { _uniqueID }
      override open var capabilityMask: Int { _capabilityMask }
      override open var pointingDeviceType: NSEvent.PointingDeviceType { _pointingDeviceType }
      override open var isEnteringProximity: Bool { _isEnteringProximity }
      override open var phase: NSEvent.Phase { _phase }
      override open var stage: Int { _stage }
      override open var stageTransition: CGFloat { _stageTransition }
      override open var associatedEventsMask: NSEvent.EventTypeMask { _associatedEventsMask }
      override open var pressureBehavior: NSEvent.PressureBehavior { _pressureBehavior }

      override open class func startPeriodicEvents(
        afterDelay delay: TimeInterval, withPeriod period: TimeInterval
      ) {
        _startPeriodicEvents(
          delay,
          period)
      }

      override open class func stopPeriodicEvents() { _stopPeriodicEvents() }
      override open class func mouseEvent(
        with type: NSEvent.EventType,
        location: NSPoint,
        modifierFlags flags: NSEvent.ModifierFlags,
        timestamp time: TimeInterval,
        windowNumber wNum: Int,
        context unusedPassNil: NSGraphicsContext?,
        eventNumber eNum: Int,
        clickCount cNum: Int,
        pressure: Float
      )
        -> NSEvent?
      {
        _mouseEvent(type, location, flags, time, wNum, unusedPassNil, eNum, cNum, pressure)
      }

      override open class func keyEvent(
        with type: NSEvent.EventType,
        location: NSPoint,
        modifierFlags flags: NSEvent.ModifierFlags,
        timestamp time: TimeInterval,
        windowNumber wNum: Int,
        context unusedPassNil: NSGraphicsContext?,
        characters keys: String,
        charactersIgnoringModifiers ukeys: String,
        isARepeat flag: Bool,
        keyCode code: UInt16
      )
        -> NSEvent?
      {
        _keyEvent(
          type,
          location,
          flags,
          time,
          wNum,
          unusedPassNil,
          keys,
          ukeys,
          flag,
          code)
      }

      override open class func enterExitEvent(
        with type: NSEvent.EventType,
        location: NSPoint,
        modifierFlags flags: NSEvent.ModifierFlags,
        timestamp time: TimeInterval,
        windowNumber wNum: Int,
        context unusedPassNil: NSGraphicsContext?,
        eventNumber eNum: Int,
        trackingNumber tNum: Int,
        userData data: UnsafeMutableRawPointer?
      )
        -> NSEvent?
      {
        _enterExitEvent(
          type,
          location,
          flags,
          time,
          wNum,
          unusedPassNil,
          eNum,
          tNum,
          data)
      }

      override open class func otherEvent(
        with type: NSEvent.EventType,
        location: NSPoint,
        modifierFlags flags: NSEvent.ModifierFlags,
        timestamp time: TimeInterval,
        windowNumber wNum: Int,
        context unusedPassNil: NSGraphicsContext?,
        subtype: Int16,
        data1 d1: Int,
        data2 d2: Int
      )
        -> NSEvent?
      {
        _otherEvent(
          type,
          location,
          flags,
          time,
          wNum,
          unusedPassNil,
          subtype,
          d1,
          d2)
      }

      override open class func addGlobalMonitorForEvents(
        matching mask: NSEvent.EventTypeMask,
        handler block: @escaping (NSEvent) -> Void
      )
        -> Any?
      {
        _addGlobalMonitorForEvents(mask, block)
      }

      override open class func addLocalMonitorForEvents(
        matching mask: NSEvent.EventTypeMask,
        handler block: @escaping (NSEvent) -> NSEvent?
      )
        -> Any?
      {
        _addLocalMonitorForEvents(mask, block)
      }

      override open class func removeMonitor(_ eventMonitor: Any) { _removeMonitor(eventMonitor) }

      override open func characters(
        byApplyingModifiers modifiers: NSEvent
          .ModifierFlags
      )
        -> String?
      { _charactersbyApplyingModifiers(modifiers) }
      override open func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
        _touches(phase, view)
      }
      override open func allTouches() -> Set<NSTouch> { _allTouches() }
      override open func touches(for view: NSView) -> Set<NSTouch> { _touchesForView(view) }
      override open func coalescedTouches(for touch: NSTouch) -> [NSTouch] {
        _coalescedTouches(touch)
      }
      override open func trackSwipeEvent(
        options: NSEvent.SwipeTrackingOptions = [],
        dampenAmountThresholdMin minDampenThreshold: CGFloat,
        max maxDampenThreshold: CGFloat,
        usingHandler trackingHandler: @escaping (
          CGFloat,
          NSEvent.Phase,
          Bool,
          UnsafeMutablePointer<ObjCBool>
        ) -> Void
      ) {
        _trackSwipeEvent(options, minDampenThreshold, maxDampenThreshold, trackingHandler)
      }

      // MARK: Public

      static nonisolated(unsafe) public var _isSwipeTrackingFromScrollEventsEnabled = false

      static nonisolated(unsafe) public var _startPeriodicEvents:
        @Sendable (_ delay: TimeInterval, _ period: TimeInterval) -> Void = { _, _ in fatalError() }

      static nonisolated(unsafe) public var _stopPeriodicEvents: @Sendable () -> Void = {
        fatalError()
      }

      static nonisolated(unsafe) public var _mouseEvent:
        @Sendable (
          _ type: NSEvent.EventType,
          _ location: NSPoint,
          _ flags: NSEvent.ModifierFlags,
          _ time: TimeInterval,
          _ wNum: Int,
          _ unusedPassNil: NSGraphicsContext?,
          _ eNum: Int,
          _ cNum: Int,
          _ pressure: Float
        )
          -> NSEvent = { _, _, _, _, _, _, _, _, _ in fatalError() }

      static nonisolated(unsafe) public var _keyEvent:
        @Sendable (
          _ type: NSEvent.EventType,
          _ location: NSPoint,
          _ flags: NSEvent.ModifierFlags,
          _ time: TimeInterval,
          _ wNum: Int,
          _ unusedPassNil: NSGraphicsContext?,
          _ keys: String,
          _ ukeys: String,
          _ flag: Bool,
          _ code: UInt16
        )
          -> NSEvent? = {
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _ in
            fatalError()
          }

      static nonisolated(unsafe) public var _enterExitEvent:
        @Sendable (
          _ type: NSEvent.EventType,
          _ location: NSPoint,
          _ flags: NSEvent.ModifierFlags,
          _ time: TimeInterval,
          _ wNum: Int,
          _ unusedPassNil: NSGraphicsContext?,
          _ eNum: Int,
          _ tNum: Int,
          _ data: UnsafeMutableRawPointer?
        )
          -> NSEvent? = {
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _ in fatalError()
          }

      static nonisolated(unsafe) public var _otherEvent:
        @Sendable (
          _ type: NSEvent.EventType,
          _ location: NSPoint,
          _ flags: NSEvent.ModifierFlags,
          _ time: TimeInterval,
          _ wNum: Int,
          _ context: NSGraphicsContext?,
          _ subtype: Int16,
          _ d1: Int,
          _ d2: Int
        )
          -> NSEvent? = {
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _,
            _ in fatalError()
          }

      static nonisolated(unsafe) public var _mouseLocation: NSPoint = .zero

      static nonisolated(unsafe) public var _modifierFlags: NSEvent.ModifierFlags = []

      static nonisolated(unsafe) public var _pressedMouseButtons = 0

      static nonisolated(unsafe) public var _doubleClickInterval: TimeInterval = 0

      static nonisolated(unsafe) public var _keyRepeatDelay: TimeInterval = 0

      static nonisolated(unsafe) public var _keyRepeatInterval: TimeInterval = 0

      static nonisolated(unsafe) public var _addGlobalMonitorForEvents:
        @Sendable (
          _ mask: NSEvent.EventTypeMask,
          _ block: @escaping (NSEvent) -> Void
        )
          -> Any? = { _, _ in fatalError() }

      static nonisolated(unsafe) public var _addLocalMonitorForEvents:
        @Sendable (
          _ mask: NSEvent.EventTypeMask,
          _ block: @escaping (NSEvent) -> NSEvent?
        )
          -> Any? = { _, _ in fatalError() }

      static nonisolated(unsafe) public var _removeMonitor:
        @Sendable (_ eventMonitor: Any) -> Void = { _ in fatalError() }

      public var _type: NSEvent.EventType = .keyDown

      public var _modifierFlags: NSEvent.ModifierFlags = []

      public var _timestamp: TimeInterval = 0

      public var _window: NSWindow? = nil

      public var _windowNumber = 0

      public var _context: NSGraphicsContext? = nil

      public var _clickCount = 0

      public var _buttonNumber = 0

      public var _eventNumber = 0

      public var _pressure: Float = 0

      public var _locationInWindow: NSPoint = .zero

      public var _deltaX: CGFloat = 0

      public var _deltaY: CGFloat = 0

      public var _deltaZ: CGFloat = 0

      public var _hasPreciseScrollingDeltas = false

      public var _scrollingDeltaX: CGFloat = 0

      public var _scrollingDeltaY: CGFloat = 0

      public var _momentumPhase: NSEvent.Phase = .began

      public var _isDirectionInvertedFromDevice = false

      public var _characters: String? = nil

      public var _charactersIgnoringModifiers: String? = nil

      public var _charactersbyApplyingModifiers:
        @Sendable (_ modifiers: NSEvent.ModifierFlags) -> String? = { _ in fatalError() }

      public var _isARepeat = false

      public var _keyCode: UInt16 = 0

      public var _trackingNumber = 0

      public var _userData: UnsafeMutableRawPointer? = nil

      public var _trackingArea: NSTrackingArea? = nil

      public var _subtype: NSEvent.EventSubtype = .mouseEvent

      public var _data1 = 0

      public var _data2 = 0

      public var _cgEvent: CGEvent? = nil

      public var _magnification: CGFloat = 0

      public var _deviceID = 0

      public var _rotation: Float = 0

      public var _absoluteX = 0

      public var _absoluteY = 0

      public var _absoluteZ = 0

      public var _buttonMask: NSEvent.ButtonMask = .penTip

      public var _tilt: NSPoint = .zero

      public var _tangentialPressure: Float = 0

      public var _vendorDefined: Any = 0

      public var _vendorID = 0

      public var _tabletID = 0

      public var _pointingDeviceID = 0

      public var _systemTabletID = 0

      public var _vendorPointingDeviceType = 0

      public var _pointingDeviceSerialNumber = 0

      public var _uniqueID: UInt64 = 0

      public var _capabilityMask = 0

      public var _pointingDeviceType: NSEvent.PointingDeviceType = .cursor

      public var _isEnteringProximity = false

      public var _touches: @Sendable (_ phase: NSTouch.Phase, _ view: NSView?) -> Set<NSTouch> = {
        _, _ in []
      }

      public var _allTouches: @Sendable () -> Set<NSTouch> = { fatalError() }

      public var _touchesForView: @Sendable (_ view: NSView) -> Set<NSTouch> = { _ in fatalError() }

      public var _coalescedTouches: @Sendable (_ touch: NSTouch) -> [NSTouch] = { _ in fatalError()
      }

      public var _phase: NSEvent.Phase = .began

      public var _stage = 0

      public var _stageTransition: CGFloat = 0

      public var _associatedEventsMask: NSEvent.EventTypeMask = .appKitDefined

      public var _pressureBehavior: NSEvent.PressureBehavior = .primaryAccelerator

      public var _trackSwipeEvent:
        @Sendable (
          _ options: NSEvent.SwipeTrackingOptions,
          _ minDampenThreshold: CGFloat,
          _ maxDampenThreshold: CGFloat,
          _ trackingHandler: (CGFloat, NSEvent.Phase, Bool, UnsafeMutablePointer<ObjCBool>) -> Void
        )
          -> Void = { _, _, _, _ in fatalError() }

    }
  }
#endif
