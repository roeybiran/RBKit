import AppKit

extension NSWorkspace {
  open class Mock: NSWorkspace {

    // MARK: Lifecycle

    public init(
      _frontmostApplication: NSRunningApplication? = nil,
      _runningApplications: [NSRunningApplication] = [NSRunningApplication](),
      _notificationCenter: NotificationCenter = NotificationCenter.default,
      _fileLabels: [String] = [],
      _fileLabelColors: [NSColor] = [],
      _menuBarOwningApplication: NSRunningApplication? = nil
    ) {
      self._frontmostApplication = _frontmostApplication
      self._runningApplications = _runningApplications
      self._notificationCenter = _notificationCenter
      self._fileLabels = _fileLabels
      self._fileLabelColors = _fileLabelColors
      self._menuBarOwningApplication = _menuBarOwningApplication
    }

    // MARK: Open

    open override var runningApplications: [NSRunningApplication] {
      _runningApplications
    }

    open override var frontmostApplication: NSRunningApplication? {
      _frontmostApplication
    }

    open override var notificationCenter: NotificationCenter {
      _notificationCenter
    }

    @available(macOS 10.6, *)
    open override var fileLabels: [String] {
      _fileLabels
    }

    @available(macOS 10.6, *)
    open override var fileLabelColors: [NSColor] {
      _fileLabelColors
    }

    @available(macOS 10.7, *)
    open override var menuBarOwningApplication: NSRunningApplication? {
      _menuBarOwningApplication
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

    public var _notificationCenter: NotificationCenter = NotificationCenter.default

    public var _fileLabels = [String]() {
      willSet {
        willChangeValue(forKey: #keyPath(NSWorkspace.fileLabels))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSWorkspace.fileLabels))
      }
    }

    public var _fileLabelColors = [NSColor]() {
      willSet {
        willChangeValue(forKey: #keyPath(NSWorkspace.fileLabelColors))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSWorkspace.fileLabelColors))
      }
    }

    public var _menuBarOwningApplication: NSRunningApplication? {
      willSet {
        willChangeValue(forKey: #keyPath(NSWorkspace.menuBarOwningApplication))
      }
      didSet {
        didChangeValue(forKey: #keyPath(NSWorkspace.menuBarOwningApplication))
      }
    }

  }
}
