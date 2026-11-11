import SwiftUI
import Testing

@testable import PermissionsKit

struct PermissionTests {
  @Test
  func `accessibility permission should have correct properties`() {
    let permission = Permission.accessibility(reason: "test")

    #expect(permission == Permission(kind: .accessibility, required: true, reason: "test"))
  }

  @Test
  func `recording permission should have correct properties`() {
    let permission = Permission.recording(reason: "test")

    #expect(permission == Permission(kind: .recording, required: true, reason: "test"))
  }

  @Test
  func `full disk access permission should have correct properties`() {
    let permission = Permission.fullDiskAccess(reason: "test")

    #expect(permission == Permission(kind: .fullDiskAccess, required: true, reason: "test"))
  }

  @Test
  func `optional permissions should have correct required flag`() {
    let accessibility = Permission.accessibility(reason: "test", required: false)
    let recording = Permission.recording(reason: "test", required: false)
    let fullDiskAccess = Permission.fullDiskAccess(reason: "test", required: false)

    #expect(accessibility == Permission(kind: .accessibility, required: false, reason: "test"))
    #expect(recording == Permission(kind: .recording, required: false, reason: "test"))
    #expect(fullDiskAccess == Permission(kind: .fullDiskAccess, required: false, reason: "test"))
  }

  @Test
  func `required permissions should have correct required flag`() {
    let accessibility = Permission.accessibility(reason: "test", required: true)
    let recording = Permission.recording(reason: "test", required: true)
    let fullDiskAccess = Permission.fullDiskAccess(reason: "test", required: true)

    #expect(accessibility == Permission(kind: .accessibility, required: true, reason: "test"))
    #expect(recording == Permission(kind: .recording, required: true, reason: "test"))
    #expect(fullDiskAccess == Permission(kind: .fullDiskAccess, required: true, reason: "test"))
  }

  @Test
  func `default required flag should be true`() {
    let accessibility = Permission.accessibility(reason: "test")
    let recording = Permission.recording(reason: "test")
    let fullDiskAccess = Permission.fullDiskAccess(reason: "test")

    #expect(accessibility == Permission(kind: .accessibility, required: true, reason: "test"))
    #expect(recording == Permission(kind: .recording, required: true, reason: "test"))
    #expect(fullDiskAccess == Permission(kind: .fullDiskAccess, required: true, reason: "test"))
  }

  @Test
  func `accessibility title should be correct`() {
    let permission = Permission.accessibility(reason: "test")
    #expect(permission.title == "Accessibility")
  }

  @Test
  func `recording title should be correct`() {
    let permission = Permission.recording(reason: "test")
    #expect(permission.title == "Screen & System Audio Recording")
  }

  @Test
  func `full disk access title should be correct`() {
    let permission = Permission.fullDiskAccess(reason: "test")
    #expect(permission.title == "Full Disk Access")
  }

  @Test
  func `accessibility symbol name should be correct`() {
    let permission = Permission.accessibility(reason: "test")
    #expect(permission.symbolName == "accessibility")
  }

  @Test
  func `recording symbol name should be correct`() {
    let permission = Permission.recording(reason: "test")
    #expect(permission.symbolName == "record.circle")
  }

  @Test
  func `full disk access symbol name should be correct`() {
    let permission = Permission.fullDiskAccess(reason: "test")
    #expect(permission.symbolName == "externaldrive")
  }

  @Test
  func `accessibility accent color should be correct`() {
    let permission = Permission.accessibility(reason: "test")
    #expect(permission.accentColor == .blue)
  }

  @Test
  func `recording accent color should be correct`() {
    let permission = Permission.recording(reason: "test")
    #expect(permission.accentColor == .red)
  }

  @Test
  func `full disk access accent color should be correct`() {
    let permission = Permission.fullDiskAccess(reason: "test")
    #expect(permission.accentColor == .gray)
  }

  @Test
  func `accessibility settings anchor should be correct`() {
    let permission = Permission.accessibility(reason: "test")
    #expect(permission.settingsAnchor == "Privacy_Accessibility")
  }

  @Test
  func `recording settings anchor should be correct`() {
    let permission = Permission.recording(reason: "test")
    #expect(permission.settingsAnchor == "Privacy_ScreenCapture")
  }

  @Test
  func `full disk access settings anchor should be correct`() {
    let permission = Permission.fullDiskAccess(reason: "test")
    #expect(permission.settingsAnchor == "Privacy_AllFiles")
  }
}
