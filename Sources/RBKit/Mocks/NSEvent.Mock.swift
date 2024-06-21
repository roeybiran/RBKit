import AppKit

// MARK: - NSEventMock

extension NSEvent {
  open class Mock: NSEvent {
    override open var type: NSEvent.EventType { _type }
    public var _type: NSEvent.EventType = .keyDown

    override open var modifierFlags: NSEvent.ModifierFlags { _modifierFlags }
    public var _modifierFlags: NSEvent.ModifierFlags = []

    override open var timestamp: TimeInterval { _timestamp }
    public var _timestamp: TimeInterval = 0

    weak override open var window: NSWindow? { _window }
    public var _window: NSWindow? = nil

    override open var windowNumber: Int { _windowNumber }
    public var _windowNumber: Int = 0

    override open var context: NSGraphicsContext? { _context }
    public var _context: NSGraphicsContext? = nil

    override open var clickCount: Int { _clickCount }
    public var _clickCount: Int = 0

    override open var buttonNumber: Int { _buttonNumber }
    public var _buttonNumber: Int = 0

    override open var eventNumber: Int { _eventNumber }
    public var _eventNumber: Int = 0

    override open var pressure: Float { _pressure }
    public var _pressure: Float = 0

    override open var locationInWindow: NSPoint { _locationInWindow }
    public var _locationInWindow: NSPoint = .zero

    override open var deltaX: CGFloat { _deltaX }
    public var _deltaX: CGFloat = 0

    override open var deltaY: CGFloat { _deltaY }
    public var _deltaY: CGFloat = 0

    override open var deltaZ: CGFloat { _deltaZ }
    public var _deltaZ: CGFloat = 0

    override open var hasPreciseScrollingDeltas: Bool { _hasPreciseScrollingDeltas }
    public var _hasPreciseScrollingDeltas: Bool = false

    override open var scrollingDeltaX: CGFloat { _scrollingDeltaX }
    public var _scrollingDeltaX: CGFloat = 0

    override open var scrollingDeltaY: CGFloat { _scrollingDeltaY }
    public var _scrollingDeltaY: CGFloat = 0

    override open var momentumPhase: NSEvent.Phase { _momentumPhase }
    public var _momentumPhase: NSEvent.Phase = .began

    override open var isDirectionInvertedFromDevice: Bool { _isDirectionInvertedFromDevice }
    public var _isDirectionInvertedFromDevice: Bool = false

    override open var characters: String? { _characters }
    public var _characters: String? = nil

    override open var charactersIgnoringModifiers: String? { _charactersIgnoringModifiers }
    public var _charactersIgnoringModifiers: String? = nil

    override open func characters(byApplyingModifiers modifiers: NSEvent.ModifierFlags) -> String? { _charactersbyApplyingModifiers(modifiers) }
    public var _charactersbyApplyingModifiers: (_ modifiers: NSEvent.ModifierFlags) -> String? = { _ in fatalError() }

    override open var isARepeat: Bool { _isARepeat }
    public var _isARepeat: Bool = false

    override open var keyCode: UInt16 { _keyCode }
    public var _keyCode: UInt16 = 0

    override open var trackingNumber: Int { _trackingNumber }
    public var _trackingNumber: Int = 0

    override open var userData: UnsafeMutableRawPointer? { _userData }
    public var _userData: UnsafeMutableRawPointer? = nil

    override open var trackingArea: NSTrackingArea? { _trackingArea }
    public var _trackingArea: NSTrackingArea? = nil

    override open var subtype: NSEvent.EventSubtype { _subtype }
    public var _subtype: NSEvent.EventSubtype = .mouseEvent

    override open var data1: Int { _data1 }
    public var _data1: Int = 0

    override open var data2: Int { _data2 }
    public var _data2: Int = 0

    override open var cgEvent: CGEvent? { _cgEvent }
    public var _cgEvent: CGEvent? = nil

    // override open class var isMouseCoalescingEnabled: Bool { _isMouseCoalescingEnabled }

    override open var magnification: CGFloat { _magnification }
    public var _magnification: CGFloat = 0

    override open var deviceID: Int { _deviceID }
    public var _deviceID: Int = 0

    override open var rotation: Float { _rotation }
    public var _rotation: Float = 0

    override open var absoluteX: Int { _absoluteX }
    public var _absoluteX: Int = 0

    override open var absoluteY: Int { _absoluteY }
    public var _absoluteY: Int = 0

    override open var absoluteZ: Int { _absoluteZ }
    public var _absoluteZ: Int = 0

    override open var buttonMask: NSEvent.ButtonMask { _buttonMask }
    public var _buttonMask: NSEvent.ButtonMask = .penTip

    override open var tilt: NSPoint { _tilt }
    public var _tilt: NSPoint = .zero

    override open var tangentialPressure: Float { _tangentialPressure }
    public var _tangentialPressure: Float = 0

    override open var vendorDefined: Any { _vendorDefined }
    public var _vendorDefined: Any = 0

    override open var vendorID: Int { _vendorID }
    public var _vendorID: Int = 0

    override open var tabletID: Int { _tabletID }
    public var _tabletID: Int = 0

    override open var pointingDeviceID: Int { _pointingDeviceID }
    public var _pointingDeviceID: Int = 0

    override open var systemTabletID: Int { _systemTabletID }
    public var _systemTabletID: Int = 0

    override open var vendorPointingDeviceType: Int { _vendorPointingDeviceType }
    public var _vendorPointingDeviceType: Int = 0

    override open var pointingDeviceSerialNumber: Int { _pointingDeviceSerialNumber }
    public var _pointingDeviceSerialNumber: Int = 0

    override open var uniqueID: UInt64 { _uniqueID }
    public var _uniqueID: UInt64 = 0

    override open var capabilityMask: Int { _capabilityMask }
    public var _capabilityMask: Int = 0

    override open var pointingDeviceType: NSEvent.PointingDeviceType { _pointingDeviceType }
    public var _pointingDeviceType: NSEvent.PointingDeviceType = .cursor

    override open var isEnteringProximity: Bool { _isEnteringProximity }
    public var _isEnteringProximity: Bool = false

    override open func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> { _touches(phase, view) }
    public var _touches: (_ phase: NSTouch.Phase, _ view: NSView?) -> Set<NSTouch> = { _, _ in [] }

    override open func allTouches() -> Set<NSTouch> { _allTouches() }
    public var _allTouches: () -> Set<NSTouch> = { fatalError() }

    override open func touches(for view: NSView) -> Set<NSTouch> { _touchesForView(view) }
    public var _touchesForView: (_ view: NSView) -> Set<NSTouch> = { _ in fatalError() }

    override open func coalescedTouches(for touch: NSTouch) -> [NSTouch] { _coalescedTouches(touch) }
    public var _coalescedTouches: (_ touch: NSTouch) -> [NSTouch] = { _ in fatalError() }

    override open var phase: NSEvent.Phase { _phase }
    public var _phase: NSEvent.Phase = .began

    override open var stage: Int { _stage }
    public var _stage: Int = 0

    override open var stageTransition: CGFloat { _stageTransition }
    public var _stageTransition: CGFloat = 0

    override open var associatedEventsMask: NSEvent.EventTypeMask { _associatedEventsMask }
    public var _associatedEventsMask: NSEvent.EventTypeMask = .appKitDefined

    override open var pressureBehavior: NSEvent.PressureBehavior { _pressureBehavior }
    public var _pressureBehavior: NSEvent.PressureBehavior = .primaryAccelerator

    override open class var isSwipeTrackingFromScrollEventsEnabled: Bool { _isSwipeTrackingFromScrollEventsEnabled }
    static public var _isSwipeTrackingFromScrollEventsEnabled: Bool = false

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
    public var _trackSwipeEvent: (
      _ options: NSEvent.SwipeTrackingOptions,
      _ minDampenThreshold: CGFloat,
      _ maxDampenThreshold: CGFloat,
      _ trackingHandler: (CGFloat, NSEvent.Phase, Bool, UnsafeMutablePointer<ObjCBool>) -> Void
    ) -> Void = { _, _, _, _ in fatalError() }

    override open class func startPeriodicEvents(afterDelay delay: TimeInterval, withPeriod period: TimeInterval) { _startPeriodicEvents(delay, period) }
    static public var _startPeriodicEvents: (_ delay: TimeInterval, _ period: TimeInterval) -> Void = { _, _ in fatalError() }

    override open class func stopPeriodicEvents() { _stopPeriodicEvents() }
    static public var _stopPeriodicEvents: () -> Void = { fatalError() }

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
    ) -> NSEvent? {
      _mouseEvent(type, location, flags, time, wNum, unusedPassNil, eNum, cNum, pressure)
    }

    static public var _mouseEvent: (
      _ type: NSEvent.EventType,
      _ location: NSPoint,
      _ flags: NSEvent.ModifierFlags,
      _ time: TimeInterval,
      _ wNum: Int,
      _ unusedPassNil: NSGraphicsContext?,
      _ eNum: Int,
      _ cNum: Int,
      _ pressure: Float
    ) -> NSEvent = { _, _, _, _, _, _, _, _, _ in fatalError() }


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
    ) -> NSEvent? {
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
        code
      )
    }
    static public var _keyEvent: (
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
    ) -> NSEvent? = {
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
    ) -> NSEvent? {
      _enterExitEvent(
        type,
        location,
        flags,
        time,
        wNum,
        unusedPassNil,
        eNum,
        tNum,
        data
      )
    }
    static public var _enterExitEvent: (
      _ type: NSEvent.EventType,
      _ location: NSPoint,
      _ flags: NSEvent.ModifierFlags,
      _ time: TimeInterval,
      _ wNum: Int,
      _ unusedPassNil: NSGraphicsContext?,
      _ eNum: Int,
      _ tNum: Int,
      _ data: UnsafeMutableRawPointer?
    ) -> NSEvent? = {
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
    ) -> NSEvent? {
      _otherEvent(
        type,
        location,
        flags,
        time,
        wNum,
        unusedPassNil,
        subtype,
        d1,
        d2
      )
    }

    static public var _otherEvent: (
      _ type: NSEvent.EventType,
      _ location: NSPoint,
      _ flags: NSEvent.ModifierFlags,
      _ time: TimeInterval,
      _ wNum: Int,
      _ context: NSGraphicsContext?,
      _ subtype: Int16,
      _ d1: Int,
      _ d2: Int
    ) -> NSEvent? = {
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

    override open class var mouseLocation: NSPoint { _mouseLocation }
    static public var _mouseLocation: NSPoint = .zero

    override open class var modifierFlags: NSEvent.ModifierFlags { _modifierFlags }
    static public var _modifierFlags: NSEvent.ModifierFlags = []

    override open class var pressedMouseButtons: Int { _pressedMouseButtons }
    static public var _pressedMouseButtons: Int = 0

    override open class var doubleClickInterval: TimeInterval { _doubleClickInterval }
    static public var _doubleClickInterval: TimeInterval = 0

    override open class var keyRepeatDelay: TimeInterval { _keyRepeatDelay }
    static public var _keyRepeatDelay: TimeInterval = 0

    override open class var keyRepeatInterval: TimeInterval { _keyRepeatInterval }
    static public var _keyRepeatInterval: TimeInterval = 0

    override open class func addGlobalMonitorForEvents(
      matching mask: NSEvent.EventTypeMask,
      handler block: @escaping (NSEvent) -> Void
    ) -> Any? {
      _addGlobalMonitorForEvents(mask, block)
    }

    static public var _addGlobalMonitorForEvents: (
      _ mask: NSEvent.EventTypeMask,
      _ block: @escaping (NSEvent) -> Void
    ) -> Any? = { _, _ in fatalError() }

    override open class func addLocalMonitorForEvents(
      matching mask: NSEvent.EventTypeMask,
      handler block: @escaping (NSEvent) -> NSEvent?
    ) -> Any? {
      _addLocalMonitorForEvents(mask, block)
    }
    static public var _addLocalMonitorForEvents: (
      _ mask: NSEvent.EventTypeMask,
      _ block: @escaping (NSEvent) -> NSEvent?
    ) -> Any? = { _, _ in fatalError() }

    override open class func removeMonitor(_ eventMonitor: Any) { _removeMonitor(eventMonitor) }
    static public var _removeMonitor: (_ eventMonitor: Any) -> Void = { _ in fatalError() }
  }
}
