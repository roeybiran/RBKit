import Foundation
import Testing
@testable import RBKit

struct CrashReportTests {
  @Test
  func `init`() {
    let url = URL(fileURLWithPath: "/test.ips")
    let date = Date()
    let contents = "Test crash report contents"

    let report = CrashReport(url: url, date: date, contents: contents)

    #expect(report.url == url)
    #expect(report.date == date)
    #expect(report.contents == contents)
  }
}
