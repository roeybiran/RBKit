import AppKit

extension NSRunningApplication {
  open class Mock: NSRunningApplication, @unchecked Sendable {

    // MARK: Lifecycle

    public init(
      _isTerminated: Bool = false,
      _isFinishedLaunching: Bool = true,
      _isHidden: Bool = false,
      _isActive: Bool = false,
      _ownsMenuBar: Bool = false,
      _activationPolicy: NSApplication.ActivationPolicy = .regular,
      _localizedName: String? = nil,
      _bundleIdentifier: String? = nil,
      _bundleURL: URL? = nil,
      _executableURL: URL? = nil,
      _processIdentifier: pid_t = 0,
      _launchDate: Date? = nil,
      _icon _: NSImage? = nil,
      _executableArchitecture: Int = 0
    ) {
      self._isTerminated = _isTerminated
      self._isFinishedLaunching = _isFinishedLaunching
      self._isHidden = _isHidden
      self._isActive = _isActive
      self._ownsMenuBar = _ownsMenuBar
      self._activationPolicy = _activationPolicy
      self._localizedName = _localizedName
      self._bundleIdentifier = _bundleIdentifier
      self._bundleURL = _bundleURL
      self._executableURL = _executableURL
      self._processIdentifier = _processIdentifier
      self._launchDate = _launchDate
      self._executableArchitecture = _executableArchitecture
    }

    // MARK: Open

    override open var isTerminated: Bool { _isTerminated }
    override open var isFinishedLaunching: Bool { _isFinishedLaunching }
    override open var isHidden: Bool { _isHidden }
    override open var isActive: Bool { _isActive }
    override open var ownsMenuBar: Bool { _ownsMenuBar }
    override open var activationPolicy: NSApplication.ActivationPolicy { _activationPolicy }
    override open var localizedName: String? { _localizedName }
    override open var bundleIdentifier: String? { _bundleIdentifier }
    override open var bundleURL: URL? { _bundleURL }
    override open var executableURL: URL? { _executableURL }
    override open var processIdentifier: pid_t { _processIdentifier }
    override open var launchDate: Date? { _launchDate }
    override open var icon: NSImage? { _icon }
    override open var executableArchitecture: Int { _executableArchitecture }

    open override func addObserver(
      _ observer: NSObject,
      forKeyPath keyPath: String,
      options: NSKeyValueObservingOptions = [],
      context: UnsafeMutableRawPointer?
    ) {
      _addObserver(observer, keyPath, options, context)
      super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    }

    // MARK: Public

    public var _addObserver: (
      _ observer: NSObject,
      _ keyPath: String,
      _ options: NSKeyValueObservingOptions,
      _ context: UnsafeMutableRawPointer?
    ) -> Void = { _, _, _, _ in }

    public var _isActive: Bool

    public var _ownsMenuBar: Bool

    public var _localizedName: String?

    public var _bundleIdentifier: String?

    public var _bundleURL: URL?

    public var _executableURL: URL?

    public var _processIdentifier: pid_t

    public var _launchDate: Date?

    public var _icon: NSImage?

    public var _executableArchitecture: Int

    public var _isTerminated: Bool {
      willSet {
        willChangeValue(forKey: #keyPath(NSRunningApplication.isTerminated))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSRunningApplication.isTerminated))
      }
    }

    public var _isFinishedLaunching: Bool {
      willSet {
        willChangeValue(forKey: #keyPath(NSRunningApplication.isFinishedLaunching))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSRunningApplication.isFinishedLaunching))
      }
    }

    public var _isHidden: Bool {
      willSet {
        willChangeValue(forKey: #keyPath(NSRunningApplication.isHidden))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSRunningApplication.isHidden))
      }
    }

    public var _activationPolicy: NSApplication.ActivationPolicy {
      willSet {
        willChangeValue(forKey: #keyPath(NSRunningApplication.activationPolicy))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSRunningApplication.activationPolicy))
      }
    }

  }
}
