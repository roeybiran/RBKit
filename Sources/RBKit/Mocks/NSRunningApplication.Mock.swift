import AppKit

extension NSRunningApplication {
  open class Mock: NSRunningApplication {
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
      _executableArchitecture: Int = 0)
    {
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

    // MARK: Internal

    public var _isTerminated: Bool
    public var _isFinishedLaunching: Bool
    public var _isHidden: Bool
    public var _isActive: Bool
    public var _ownsMenuBar: Bool
    public var _activationPolicy: NSApplication.ActivationPolicy
    public var _localizedName: String?
    public var _bundleIdentifier: String?
    public var _bundleURL: URL?
    public var _executableURL: URL?
    public var _processIdentifier: pid_t
    public var _launchDate: Date?
    public var _executableArchitecture: Int

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
    override open var executableArchitecture: Int { _executableArchitecture }
  }
}
