import AppKit
import Dependencies
import Foundation
import Testing
@testable import RBKit

@MainActor
struct CrashReporterViewModelTests {
  @Test
  func `init(report:email:), should set report and default values`() {
    let report = CrashReport(
      url: URL(fileURLWithPath: "/test.ips"),
      date: Date(),
      contents: "Test crash report",
    )
    let viewModel = CrashReporterViewModel(report: report, email: "test@example.com")

    #expect(viewModel.report.url == report.url)
    #expect(viewModel.report.contents == report.contents)
    #expect(viewModel.showCopied == false)
    #expect(viewModel.copyFailed == false)
    #expect(viewModel.copyButtonIcon == "checkmark.circle")
    #expect(viewModel.copyButtonText == "Copied")
    #expect(viewModel.copiedLabelOpacity == 0)
    #expect(viewModel.defaultLabelOpacity == 1)
    #expect(viewModel.isCopyButtonDisabled == false)
    #expect(viewModel.isCopiedLabelAccessibilityHidden == true)
    #expect(viewModel.isDefaultLabelAccessibilityHidden == false)
  }

  @Test
  func `copyToClipboard(), on success, should show copied state and reset after delay`() async {
    let report = CrashReport(
      url: URL(fileURLWithPath: "/test.ips"),
      date: Date(),
      contents: "Test contents",
    )
    let clock = TestClock()
    nonisolated(unsafe) var clearContentsCalled = false
    nonisolated(unsafe) var setStringString: String?
    nonisolated(unsafe) var setStringDataType: NSPasteboard.PasteboardType?

    let viewModel = withDependencies {
      $0.continuousClock = clock
      $0.pasteboard.clearContents = { clearContentsCalled = true }
      $0.pasteboard.setString = { string, dataType in
        setStringString = string
        setStringDataType = dataType
        return true
      }
    } operation: {
      CrashReporterViewModel(report: report, email: "test@example.com")
    }

    viewModel.copyToClipboard()

    #expect(clearContentsCalled == true)
    #expect(setStringString == report.contents)
    #expect(setStringDataType == .string)
    #expect(viewModel.showCopied == true)
    #expect(viewModel.copyFailed == false)
    #expect(viewModel.copyButtonIcon == "checkmark.circle")
    #expect(viewModel.copyButtonText == "Copied")
    #expect(viewModel.copiedLabelOpacity == 1)
    #expect(viewModel.defaultLabelOpacity == 0)
    #expect(viewModel.isCopyButtonDisabled == true)
    #expect(viewModel.isCopiedLabelAccessibilityHidden == false)
    #expect(viewModel.isDefaultLabelAccessibilityHidden == true)

    await Task.yield()
    await clock.advance(by: .seconds(2))
    await Task.yield()

    #expect(viewModel.showCopied == false)
    #expect(viewModel.copiedLabelOpacity == 0)
    #expect(viewModel.defaultLabelOpacity == 1)
    #expect(viewModel.isCopyButtonDisabled == false)
    #expect(viewModel.isCopiedLabelAccessibilityHidden == true)
    #expect(viewModel.isDefaultLabelAccessibilityHidden == false)
  }

  @Test
  func `copyToClipboard(), on failure, should show failed state`() {
    let report = CrashReport(
      url: URL(fileURLWithPath: "/test.ips"),
      date: Date(),
      contents: "Test contents",
    )
    let clock = TestClock()
    nonisolated(unsafe) var clearContentsCalled = false
    nonisolated(unsafe) var setStringString: String?
    nonisolated(unsafe) var setStringDataType: NSPasteboard.PasteboardType?

    let viewModel = withDependencies {
      $0.continuousClock = clock
      $0.pasteboard.clearContents = { clearContentsCalled = true }
      $0.pasteboard.setString = { string, dataType in
        setStringString = string
        setStringDataType = dataType
        return false
      }
    } operation: {
      CrashReporterViewModel(report: report, email: "test@example.com")
    }

    viewModel.copyToClipboard()

    #expect(clearContentsCalled == true)
    #expect(setStringString == report.contents)
    #expect(setStringDataType == .string)
    #expect(viewModel.showCopied == true)
    #expect(viewModel.copyFailed == true)
    #expect(viewModel.copyButtonIcon == "xmark.circle")
    #expect(viewModel.copyButtonText == "Failed")
    #expect(viewModel.copiedLabelOpacity == 1)
    #expect(viewModel.defaultLabelOpacity == 0)
    #expect(viewModel.isCopyButtonDisabled == true)
    #expect(viewModel.isCopiedLabelAccessibilityHidden == false)
    #expect(viewModel.isDefaultLabelAccessibilityHidden == true)
  }

  @Test
  func `emailReport(), should open a mailto URL with subject and body and stop the modal`() throws {
    let report = CrashReport(
      url: URL(fileURLWithPath: "/test.ips"),
      date: Date(),
      contents: "Test crash report",
    )
    let email = "support@example.com"
    nonisolated(unsafe) var openCalled = false
    nonisolated(unsafe) var openURL: URL?
    nonisolated(unsafe) var stopModalCalled = false

    let viewModel = withDependencies {
      $0.nsWorkspaceClient.open = { url in
        openCalled = true
        openURL = url
        return true
      }
      $0.nsApplicationClient.stopModal = { stopModalCalled = true }
    } operation: {
      CrashReporterViewModel(report: report, email: email)
    }

    viewModel.emailReport()

    #expect(openCalled == true)
    #expect(openURL != nil)
    #expect(openURL?.scheme == "mailto")
    #expect(openURL?.absoluteString.contains(email) == true)

    let components = URLComponents(url: try #require(openURL), resolvingAgainstBaseURL: false)
    let subjectItem = components?.queryItems?.first { $0.name == "subject" }
    let bodyItem = components?.queryItems?.first { $0.name == "body" }
    #expect(subjectItem?.value?.contains("Crash Report") == true)
    #expect(bodyItem?.value == report.contents)

    #expect(stopModalCalled == true)
  }

  @Test
  func `revealInFinder(), should activate the file viewer with the report URL`() {
    let report = CrashReport(
      url: URL(fileURLWithPath: "/test.ips"),
      date: Date(),
      contents: "Test contents",
    )
    nonisolated(unsafe) var revealCalled = false
    nonisolated(unsafe) var revealURLs = [URL]()

    let viewModel = withDependencies {
      $0.nsWorkspaceClient.activateFileViewerSelecting = { urls in
        revealCalled = true
        revealURLs = urls
      }
    } operation: {
      CrashReporterViewModel(report: report, email: "test@example.com")
    }

    viewModel.revealInFinder()

    #expect(revealCalled == true)
    #expect(revealURLs == [report.url])
  }

  @Test
  func `close(), should stop the modal`() {
    let report = CrashReport(
      url: URL(fileURLWithPath: "/test.ips"),
      date: Date(),
      contents: "Test contents",
    )
    nonisolated(unsafe) var stopModalCalled = false

    let viewModel = withDependencies {
      $0.nsApplicationClient.stopModal = { stopModalCalled = true }
    } operation: {
      CrashReporterViewModel(report: report, email: "test@example.com")
    }

    viewModel.close()

    #expect(stopModalCalled == true)
  }

  @Test
  func `create(), should return a view model with the default report`() {
    let viewModel = CrashReporterViewModel.create()

    #expect(viewModel.report.url == URL(fileURLWithPath: "/"))
    #expect(viewModel.report.contents == "")
    #expect(viewModel.showCopied == false)
    #expect(viewModel.copyFailed == false)
  }
}
