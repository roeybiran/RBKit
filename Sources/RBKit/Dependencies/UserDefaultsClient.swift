import Dependencies
import DependenciesMacros
import Foundation

// MARK: - UserDefaultsClient

@DependencyClient
public struct UserDefaultsClient: Sendable {
  public var object: @Sendable (_ forKey: String) -> Any?
  public var url: @Sendable (_ forKey: String) -> URL?
  public var array: @Sendable (_ forKey: String) -> [Any]?
  public var dictionary: @Sendable (_ forKey: String) -> [String: Any]?
  public var string: @Sendable (_ forKey: String) -> String?
  public var stringArray: @Sendable (_ forKey: String) -> [String]?
  public var data: @Sendable (_ forKey: String) -> Data?
  public var bool: @Sendable (_ forKey: String) -> Bool = { _ in false }
  public var integer: @Sendable (_ forKey: String) -> Int = { _ in 0 }
  public var float: @Sendable (_ forKey: String) -> Float = { _ in 0 }
  public var double: @Sendable (_ forKey: String) -> Double = { _ in 0 }

  public var setAny: @Sendable (_ value: Any?, _ forKey: String) -> Void
  public var setFloat: @Sendable (_ value: Float, _ forKey: String) -> Void
  public var setDouble: @Sendable (_ value: Double, _ forKey: String) -> Void
  public var setInt: @Sendable (_ value: Int, _ forKey: String) -> Void
  public var setBool: @Sendable (_ value: Bool, _ forKey: String) -> Void
  public var setURL: @Sendable (_ value: URL?, _ forKey: String) -> Void

  public var removeObject: @Sendable (_ forKey: String) -> Void
  public var register: @Sendable (_ defaults: [String: Any]) -> Void
}

// MARK: DependencyKey

extension UserDefaultsClient: DependencyKey {
  public static let liveValue: Self = {
    return Self(
      object: { UserDefaults.standard.object(forKey:$0) },
      url: { UserDefaults.standard.url(forKey: $0) },
      array: { UserDefaults.standard.array(forKey: $0) },
      dictionary: { UserDefaults.standard.dictionary(forKey: $0) },
      string: { UserDefaults.standard.string(forKey: $0) },
      stringArray: { UserDefaults.standard.stringArray(forKey: $0) },
      data: { UserDefaults.standard.data(forKey: $0) },
      bool: { UserDefaults.standard.bool(forKey: $0) },
      integer: { UserDefaults.standard.integer(forKey: $0) },
      float: { UserDefaults.standard.float(forKey: $0) },
      double: { UserDefaults.standard.double(forKey: $0) },
      setAny: { UserDefaults.standard.set($0, forKey: $1) },
      setFloat: { UserDefaults.standard.set($0, forKey: $1) },
      setDouble: { UserDefaults.standard.set($0, forKey: $1) },
      setInt: { UserDefaults.standard.set($0, forKey: $1) },
      setBool: { UserDefaults.standard.set($0, forKey: $1) },
      setURL: { UserDefaults.standard.set($0, forKey: $1) },
      removeObject: { UserDefaults.standard.removeObject(forKey: $0) },
      register: { UserDefaults.standard.register(defaults: $0) }
    )
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var userDefaultsClient: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
