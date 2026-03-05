import AppKit
import Dependencies
import Foundation
import Testing
@testable import RBKit

@Suite
struct `AppImporterItem Tests` {
  @Test
  func `init(bundleID:) should store identifier`() {
    let item = AppImporterItem(bundleID: "com.example.app")

    #expect(item.bundleID == "com.example.app")
    #expect(item.id == "com.example.app")
  }

  @Test
  func `title, with resolved application URL, should use app name`() {
    let bundleID = "com.example.app"
    let appURL = URL(fileURLWithPath: "/Applications/Test.app")

    let title = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { queriedBundleID in
        #expect(queriedBundleID == bundleID)
        return appURL
      }
    } operation: {
      AppImporterItem(bundleID: bundleID).title
    }

    #expect(title == "Test")
  }

  @Test
  func `title, with unresolved application URL, should fallback to bundleID`() {
    let bundleID = "com.missing.app"

    let title = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { queriedBundleID in
        #expect(queriedBundleID == bundleID)
        return nil
      }
    } operation: {
      AppImporterItem(bundleID: bundleID).title
    }

    #expect(title == bundleID)
  }

  @Test
  func `image, with resolved application URL, should return valid image`() {
    let image = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { _ in
        URL(fileURLWithPath: "/Applications/Test.app")
      }
    } operation: {
      AppImporterItem(bundleID: "com.example.app").image
    }

    #expect(image.isValid)
  }

  @Test
  func `image, with unresolved application URL, should return question mark icon`() {
    let image = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { _ in nil }
    } operation: {
      AppImporterItem(bundleID: "com.example.app").image
    }

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
