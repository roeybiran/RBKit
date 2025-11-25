import AppKit
import Dependencies
import Foundation
import Testing
@testable import RBKit
@testable import RBKitTestSupport

@Suite
struct `AppImporterItem Tests` {
  // MARK: - Basic Initializer Tests

  @Test
  func `Initializer with bundleID and bundleURL`() {
    let bundleID = "com.example.app"
    let bundleURL = URL(fileURLWithPath: "/Applications/Test.app")

    let item = AppImporterItem(bundleID: bundleID, bundleURL: bundleURL)

    #expect(item.bundleID == bundleID)
    #expect(item.bundleURL == bundleURL)
  }

  @Test
  func `Title`() {
    let bundleID = "com.example.app"
    let bundleURL = URL(fileURLWithPath: "/Applications/Test.app")

    let item = AppImporterItem(bundleID: bundleID, bundleURL: bundleURL)

    #expect(item.title == "Test")
  }

  @Test
  func `Title with nil bundleURL falls back to bundleID`() {
    let bundleID = "com.example.app"
    let item = AppImporterItem(bundleID: bundleID, bundleURL: nil)

    #expect(item.title == bundleID)
  }

  @Test
  func `Path`() {
    let bundleID = "com.example.app"
    let bundleURL = URL(fileURLWithPath: "/Applications/Test.app")

    let item = AppImporterItem(bundleID: bundleID, bundleURL: bundleURL)

    #expect(item.path == "/Applications/Test.app")
  }

  @Test
  func `Path with nil bundleURL returns nil`() {
    let bundleID = "com.example.app"
    let item = AppImporterItem(bundleID: bundleID, bundleURL: nil)
    #expect(item.path == nil)
  }

  // MARK: - ID Tests

  @Test
  func `ID equals bundleID`() {
    let bundleID = "com.example.app"
    let item = AppImporterItem(bundleID: bundleID, bundleURL: nil)

    #expect(item.id == bundleID)
  }

  // MARK: - RawRepresentable Tests

  @Test
  func `rawValue equals bundleID`() {
    let bundleID = "com.example.app"
    let item = AppImporterItem(bundleID: bundleID, bundleURL: nil)

    #expect(item.rawValue == bundleID)
  }

  @Test
  func `init(rawValue:) creates item with bundleID`() {
    let bundleID = "com.example.app"
    let expectedURL = URL(fileURLWithPath: "/Applications/Test.app")

    let item = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { bundleIdentifier in
        if bundleIdentifier == bundleID {
          return expectedURL
        } else {
          Issue.record()
          return nil
        }
      }
    } operation: {
      AppImporterItem(rawValue: bundleID)
    }

    #expect(item.bundleID == bundleID)
    #expect(item.bundleURL == expectedURL)
  }

  @Test
  func `init(rawValue:) with invalid bundleID creates item with nil URL`() {
    let bundleID = "com.nonexistent.app"

    let item = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { _ in nil }
    } operation: {
      AppImporterItem(rawValue: bundleID)
    }

    #expect(item.bundleID == bundleID)
    #expect(item.bundleURL == nil)
  }

  // MARK: - init(bundleID:) Tests

  @Test
  func `init(bundleID:) with valid bundleID returns item with URL`() {
    let bundleID = "com.example.app"
    let expectedURL = URL(fileURLWithPath: "/Applications/Test.app")

    let item = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { bundleIdentifier in
        if bundleIdentifier == bundleID {
          return expectedURL
        } else {
          Issue.record()
          return nil
        }
      }
    } operation: {
      AppImporterItem(bundleID: bundleID)
    }

    #expect(item.bundleID == bundleID)
    #expect(item.bundleURL == expectedURL)
  }

  @Test
  func `init(bundleID:) with invalid bundleID returns item with nil URL`() {
    let bundleID = "com.nonexistent.app"

    let item = withDependencies {
      $0.nsWorkspaceClient.urlForApplication = { _ in nil }
    } operation: {
      AppImporterItem(bundleID: bundleID)
    }

    #expect(item.bundleID == bundleID)
    #expect(item.bundleURL == nil)
  }

  // MARK: - init?(url:) Tests

  @Test
  func `init?(url:) with valid URL and bundleID returns item`() {
    let bundleID = "com.example.app"
    let url = URL(fileURLWithPath: "/Applications/Test.app")
    let mockBundle = Bundle.Mock()
    mockBundle._bundleIdentifier = bundleID

    let item = withDependencies {
      $0.bundleClient.initWithURL = { _ in mockBundle }
      $0.bundleClient.bundleIdentifier = { bundle in
        (bundle as? Bundle.Mock)?._bundleIdentifier
      }
    } operation: {
      AppImporterItem(url: url)
    }

    #expect(item != nil)
    #expect(item?.bundleID == bundleID)
    #expect(item?.bundleURL == url)
  }

  @Test
  func `init?(url:) with invalid URL returns nil`() {
    let url = URL(fileURLWithPath: "/Applications/Test.app")

    let item = withDependencies {
      $0.bundleClient.initWithURL = { _ in nil }
    } operation: {
      AppImporterItem(url: url)
    }

    #expect(item == nil)
  }

  @Test
  func `init?(url:) with URL that has no bundleIdentifier returns nil`() {
    let url = URL(fileURLWithPath: "/Applications/Test.app")
    let mockBundle = Bundle.Mock()
    mockBundle._bundleIdentifier = nil

    let item = withDependencies {
      $0.bundleClient.initWithURL = { _ in mockBundle }
      $0.bundleClient.bundleIdentifier = { bundle in
        (bundle as? Bundle.Mock)?._bundleIdentifier
      }
    } operation: {
      AppImporterItem(url: url)
    }

    #expect(item == nil)
  }

  // MARK: - Image Tests

  @Test
  func `Image with valid path returns valid image`() {
    let bundleID = "com.example.app"
    let bundleURL = URL(fileURLWithPath: "/Applications/Test.app")

    let item = AppImporterItem(bundleID: bundleID, bundleURL: bundleURL)

    let image = item.image
    // Note: image property uses NSWorkspace.shared directly, so we can't easily mock it
    // But we can verify it returns a valid image
    #expect(image.isValid)
  }

  @Test
  func `Image with nil path returns question mark icon`() {
    let bundleID = "com.example.app"
    let item = AppImporterItem(bundleID: bundleID, bundleURL: nil)

    let image = item.image
    #expect(image === NSImage.questionMark)
  }
}
