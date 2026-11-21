import AppKit
import Dependencies
import Foundation
import Observation

@MainActor
@Observable
final class CrashReporterViewModel {

  // MARK: Lifecycle

  init(report: CrashReport, email: String) {
    self.report = report
    self.email = email
  }

  // MARK: Internal

  let report: CrashReport
  let email: String
  private(set) var showCopied = false
  private(set) var copyFailed = false

  var copyButtonIcon: String {
    copyFailed ? "xmark.circle" : "checkmark.circle"
  }

  var copyButtonText: String {
    copyFailed ? "Failed" : "Copied"
  }

  var copiedLabelOpacity: Double {
    showCopied ? 1 : 0
  }

  var defaultLabelOpacity: Double {
    showCopied ? 0 : 1
  }

  var isCopyButtonDisabled: Bool {
    showCopied
  }

  var isCopiedLabelAccessibilityHidden: Bool {
    !showCopied
  }

  var isDefaultLabelAccessibilityHidden: Bool {
    showCopied
  }

  static func create() -> CrashReporterViewModel {
    CrashReporterViewModel(
      report: CrashReport(
        url: URL(fileURLWithPath: "/"),
        date: Date(),
        contents: "",
      ),
      email: String.EMAIL,
    )
  }

  func copyToClipboard() {
    pasteboardClient.clearContents()
    let result = pasteboardClient.setString(string: report.contents, dataType: .string)
    copyFailed = !result
    showCopied = true

    Task { [weak self] in
      guard let self else { return }
      try? await continuousClock.sleep(for: .seconds(2))
      showCopied = false
    }
  }

  func emailReport() {
    var components = URLComponents(string: "mailto:\(email)")
    var queryItems = [URLQueryItem]()
    queryItems.append(.init(name: "subject", value: "\(Bundle.main.appName) Crash Report"))
    queryItems.append(.init(name: "body", value: report.contents))
    components?.queryItems = queryItems

    if let url = components?.url {
      _ = workspaceClient.open(url: url)
    }
    close()
  }

  func revealInFinder() {
    workspaceClient.activateFileViewerSelecting(fileURLs: [report.url])
  }

  func close() {
    applicationClient.stopModal()
  }

  // MARK: Private

  @ObservationIgnored @Dependency(\.pasteboard) private var pasteboardClient
  @ObservationIgnored @Dependency(\.nsWorkspaceClient) private var workspaceClient
  @ObservationIgnored @Dependency(\.nsApplicationClient) private var applicationClient
  @ObservationIgnored @Dependency(\.continuousClock) private var continuousClock

}
