import AppKit
import Dependencies
import DependenciesTestSupport
import Foundation
import Testing
@testable import RBKit

struct AppImporterItemTests {
  @Test
  func `init(bundleID:) should store identifier`() {
    let item = AppImporterItem(bundleID: "com.example.app")

    #expect(item.bundleID == "com.example.app")
    #expect(item.id == "com.example.app")
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.urlForApplication = { queriedBundleID in
        #expect(queriedBundleID == "com.example.app")
        return URL(fileURLWithPath: "/Applications/Test.app")
      }
    }
  )
  func `title, with resolved application URL, should use app name`() {
    let title = AppImporterItem(bundleID: "com.example.app").title

    #expect(title == "Test")
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.urlForApplication = { queriedBundleID in
        #expect(queriedBundleID == "com.missing.app")
        return nil
      }
    }
  )
  func `title, with unresolved application URL, should fallback to bundleID`() {
    let title = AppImporterItem(bundleID: "com.missing.app").title

    #expect(title == "com.missing.app")
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.urlForApplication = { _ in
        URL(fileURLWithPath: "/Applications/Test.app")
      }
    }
  )
  func `image, with resolved application URL, should return valid image`() {
    let image = AppImporterItem(bundleID: "com.example.app").image

    #expect(image.isValid)
  }

  @Test(
    .dependencies {
      $0.nsWorkspaceClient.urlForApplication = { _ in nil }
    }
  )
  func `image, with unresolved application URL, should return question mark icon`() {
    let image = AppImporterItem(bundleID: "com.example.app").image

    #expect(image === NSImage.questionMark)
  }

  @Test
  func `Codable roundtrip should preserve bundleID`() throws {
    let original = AppImporterItem(bundleID: "com.example.app")
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(AppImporterItem.self, from: data)

    #expect(decoded == original)
  }
}
