import Dependencies
import DependenciesMacros
import Foundation

let userDefaultsPrefix = "RBCrashReporter_"
let userDefaultsKey = "\(userDefaultsPrefix)mostRecentReport"

// MARK: - CrashReporterClient

@DependencyClient
public struct CrashReporterClient: Sendable {
  public var mostRecent: @Sendable () -> CrashReport? = { nil }
}

extension CrashReporterClient {
  static func mostRecent() -> CrashReport? {
    @Dependency(\.fileManagerClient) var fileManagerClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.bundleClient) var bundleClient
    @Dependency(\.stringClient) var stringClient

    let directory = URL.libraryDirectory
      .appendingPathComponent("Logs", isDirectory: true)
      .appendingPathComponent("DiagnosticReports", isDirectory: true)

    let contents =
      (try? fileManagerClient.contentsOfDirectory(
        url: directory,
        keys: [],
        options: [],
      )) ?? []

    guard !contents.isEmpty else { return nil }

    let appName = bundleClient.main().appName
    let reports = contents
      .compactMap { url -> CrashReport? in
        guard url.pathExtension == "ips" else { return nil }

        let filename = url.deletingPathExtension().lastPathComponent
        let prefix = "\(appName)-"

        guard filename.hasPrefix(prefix) else { return nil }

        let dateTimePart = String(filename.dropFirst(prefix.count))
        let parts = dateTimePart.split(separator: "-")

        guard
          parts.count == 4,
          parts[3].count == 6
        else { return nil }

        let year = parts[0]
        let month = parts[1]
        let day = parts[2]
        let hours = parts[3].prefix(2)
        let minutes = parts[3].dropFirst(2).prefix(2)
        let seconds = parts[3].dropFirst(4)
        let timeString = "\(hours):\(minutes):\(seconds)"
        let dateString = "\(year)-\(month)-\(day)"
        let dateTimeString = "\(dateString)T\(timeString)Z"

        guard let date = try? Date(dateTimeString, strategy: .iso8601) else { return nil }
        guard let contents = try? stringClient.contentsOf(url, .utf8) else { return nil }
        return CrashReport(url: url, date: date, contents: contents)
      }
      .sorted(by: { $0.date > $1.date })

    guard let mostRecentReport = reports.first else { return nil }

    let cachedReport = userDefaultsClient.url(forKey: userDefaultsKey)
    if mostRecentReport.url == cachedReport { return nil }

    userDefaultsClient.setURL(value: mostRecentReport.url, forKey: userDefaultsKey)
    return mostRecentReport
  }
}

// MARK: DependencyKey

extension CrashReporterClient: DependencyKey {
  public static let liveValue = Self(mostRecent: { mostRecent() })
  public static let testValue = CrashReporterClient()
}

extension DependencyValues {
  public var crashReporterClient: CrashReporterClient {
    get { self[CrashReporterClient.self] }
    set { self[CrashReporterClient.self] = newValue }
  }
}
