import AppKit

extension NSWorkspace {
  open class Mock: NSWorkspace {

    // MARK: Lifecycle

    public init(
      _frontmostApplication: NSRunningApplication? = nil,
      _runningApplications: [NSRunningApplication] = [NSRunningApplication]()
    ) {
      self._frontmostApplication = _frontmostApplication
      self._runningApplications = _runningApplications
    }

    // MARK: Open

    open override var runningApplications: [NSRunningApplication] {
      _runningApplications
    }

    open override var frontmostApplication: NSRunningApplication? {
      _frontmostApplication
    }

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

    public var _frontmostApplication: NSRunningApplication? {
      willSet {
        willChangeValue(forKey: #keyPath(NSWorkspace.frontmostApplication))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSWorkspace.frontmostApplication))
      }
    }

    public var _runningApplications = [NSRunningApplication]() {
      willSet {
        willChangeValue(forKey: #keyPath(NSWorkspace.runningApplications))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSWorkspace.runningApplications))
      }
    }

  }
}
