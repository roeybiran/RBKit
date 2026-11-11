import ComposableArchitecture
import Foundation
import RBKit
import Testing

@testable import PermissionsKit

@MainActor
struct PermissionsFeatureTests {
  @Test(arguments: [(false, Permission.Status.denied), (true, Permission.Status.granted)])
  func `onAppear, with accessibility permission, should check status`(tuple: (Bool, Permission.Status)) async {
    nonisolated(unsafe) var isProcessTrustedCalls = 0
    let p = Permission(kind: .accessibility, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      let mockClient = AXClientMock()
      mockClient._isProcessTrusted = {
        isProcessTrustedCalls += 1
        return tuple.0
      }
      mockClient._isProcessTrustedWithOptions = { _ in
        tuple.0
      }
      d.axClient = mockClient
    }

    await store.send(.onAppear) {
      $0.permissions[id: p.id]?.permission.status = tuple.1
    }

    #expect(store.state.allGranted() == tuple.0)
    #expect(isProcessTrustedCalls == 1)
  }

  @Test(arguments: [(false, Permission.Status.denied), (true, Permission.Status.granted)])
  func `onAppear, with recording permission, should check status`(tuple: (Bool, Permission.Status)) async {
    nonisolated(unsafe) var preflightScreenCaptureAccessCalls = 0
    let p = Permission(kind: .recording, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.cgWindowClient.preflightScreenCaptureAccess = { @Sendable in
        preflightScreenCaptureAccessCalls += 1
        return tuple.0
      }
    }

    await store.send(.onAppear) {
      $0.permissions[id: p.id]?.permission.status = tuple.1
    }

    #expect(store.state.allGranted() == tuple.0)
    #expect(preflightScreenCaptureAccessCalls == 1)
  }

  @Test(arguments: [(false, Permission.Status.denied), (true, Permission.Status.granted)])
  func `onAppear, with full disk access permission, should check status`(tuple: (Bool, Permission.Status)) async {
    nonisolated(unsafe) var homeDirectoryForCurrentUserCalls = 0
    nonisolated(unsafe) var contentsOfDirectoryCalls = 0
    let homeDirectory = URL(fileURLWithPath: "/Users/test")
    let p = Permission(kind: .fullDiskAccess, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.fileManagerClient.homeDirectoryForCurrentUser = {
        homeDirectoryForCurrentUserCalls += 1
        return homeDirectory
      }
      d.fileManagerClient.contentsOfDirectory = { url, _, _ in
        contentsOfDirectoryCalls += 1
        #expect(url == homeDirectory.appendingPathComponent("Library/Application Support/com.apple.TCC"))
        if tuple.0 {
          return []
        } else {
          throw CocoaError(.fileReadNoPermission)
        }
      }
    }

    await store.send(.onAppear) {
      $0.permissions[id: p.id]?.permission.status = tuple.1
    }

    #expect(store.state.allGranted() == tuple.0)
    #expect(homeDirectoryForCurrentUserCalls == 1)
    #expect(contentsOfDirectoryCalls == 1)
  }

  @Test
  func `infoButtonClicked, should show the popover`() async {
    let p = Permission(kind: .accessibility, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    }

    await store.send(.infoButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.isInfoPopoverShown = true
    }
  }

  @Test
  func `infoButtonClicked, with popover already shown, should hide the popover`() async {
    let p = Permission(kind: .accessibility, reason: "foo")
    let store = TestStore(
      initialState: PermissionsFeature.State(
        permissions: [PermissionRowState(
          permission: p,
          isInfoPopoverShown: true,
        )]
      )
    ) {
      PermissionsFeature()
    }

    await store.send(.infoButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.isInfoPopoverShown = false
    }
  }

  @Test
  func `authorizeButtonClicked, with accessibility permission, should poll until authorized`() async {
    let pollAttempts = 2
    nonisolated(unsafe) var isProcessTrustedCalls = 0
    nonisolated(unsafe) var isProcessTrustedWithOptionsCalls = 0

    let p = Permission(kind: .accessibility, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.continuousClock = ImmediateClock()
      let mockClient = AXClientMock()
      mockClient._isProcessTrusted = {
        isProcessTrustedCalls += 1
        return isProcessTrustedCalls >= pollAttempts
      }
      mockClient._isProcessTrustedWithOptions = { _ in
        isProcessTrustedWithOptionsCalls += 1
        return false
      }
      d.axClient = mockClient
    }

    await store.send(.authorizeButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.permission.status = .inProgress
    }

    await store.receive(\.pollingEnded) {
      $0.permissions[id: p.id]?.permission.status = .granted
    }

    await store.finish()

    #expect(isProcessTrustedCalls == 3)
    #expect(isProcessTrustedWithOptionsCalls == 1)
  }

  @Test
  func `authorizeButtonClicked, with recording permission, should poll until authorized`() async {
    let pollAttempts = 2
    nonisolated(unsafe) var preflightScreenCaptureAccessCalls = 0
    nonisolated(unsafe) var requestScreenCaptureAccessCalls = 0

    let p = Permission(kind: .recording, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.continuousClock = ImmediateClock()
      d.cgWindowClient.preflightScreenCaptureAccess = { @Sendable in
        preflightScreenCaptureAccessCalls += 1
        return preflightScreenCaptureAccessCalls >= pollAttempts
      }
      d.cgWindowClient.requestScreenCaptureAccess = { @Sendable in
        requestScreenCaptureAccessCalls += 1
        return true
      }
    }

    await store.send(.authorizeButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.permission.status = .inProgress
    }

    await store.receive(\.pollingEnded) {
      $0.permissions[id: p.id]?.permission.status = .granted
    }

    await store.finish()

    #expect(preflightScreenCaptureAccessCalls == 3)
    #expect(requestScreenCaptureAccessCalls == 1)
  }

  @Test
  func `authorizeButtonClicked, with full disk access permission, should open settings and poll until authorized`() async {
    let pollAttempts = 2
    nonisolated(unsafe) var contentsOfDirectoryCalls = 0
    nonisolated(unsafe) var openedURLs = [URL]()
    let homeDirectory = URL(fileURLWithPath: "/Users/test")

    let p = Permission(kind: .fullDiskAccess, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.continuousClock = ImmediateClock()
      d.fileManagerClient.homeDirectoryForCurrentUser = {
        homeDirectory
      }
      d.fileManagerClient.contentsOfDirectory = { url, _, _ in
        contentsOfDirectoryCalls += 1
        #expect(url == homeDirectory.appendingPathComponent("Library/Application Support/com.apple.TCC"))
        if contentsOfDirectoryCalls >= pollAttempts {
          return []
        } else {
          throw CocoaError(.fileReadNoPermission)
        }
      }
      d.nsWorkspaceClient.open = { url in
        openedURLs.append(url)
        return true
      }
    }

    await store.send(.authorizeButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.permission.status = .inProgress
    }

    await store.receive(\.pollingEnded) {
      $0.permissions[id: p.id]?.permission.status = .granted
    }

    await store.finish()

    #expect(contentsOfDirectoryCalls == 3)
    #expect(openedURLs.map(\.absoluteString) == [
      "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    ])
  }

  @Test
  func `authorizeButtonClicked, with accessibility permission, should poll until the app becomes active again`() async {
    let p = Permission(kind: .accessibility, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.continuousClock = ImmediateClock()
      let mockClient = AXClientMock()
      mockClient._isProcessTrusted = {
        false
      }
      mockClient._isProcessTrustedWithOptions = { _ in
        false
      }
      d.axClient = mockClient
    }

    await store.send(.authorizeButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.permission.status = .inProgress
    }

    await store.send(.appearsActiveChange(true)) {
      $0.permissions[id: p.id]?.permission.status = .denied
    }

    await store.finish()
  }

  @Test
  func `authorizeButtonClicked, with recording permission, should poll until the app becomes active again`() async {
    let p = Permission(kind: .recording, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    } withDependencies: { d in
      d.continuousClock = ImmediateClock()
      d.cgWindowClient.preflightScreenCaptureAccess = { @Sendable in false }
      d.cgWindowClient.requestScreenCaptureAccess = { @Sendable in return false }
    }

    await store.send(.authorizeButtonClicked(p.id)) {
      $0.permissions[id: p.id]?.permission.status = .inProgress
    }

    await store.send(.appearsActiveChange(true)) {
      $0.permissions[id: p.id]?.permission.status = .denied
    }

    await store.finish()
  }

  @Test
  func `appearsActiveChange, with false, should do nothing`() async {
    let p = Permission(kind: .recording, reason: "foo")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [p])) {
      PermissionsFeature()
    }
    await store.send(.appearsActiveChange(false))
  }

  @Test
  func `authorizeButtonClicked, with missing permission, should do nothing`() async {
    let store = TestStore(initialState: PermissionsFeature.State()) {
      PermissionsFeature()
    }
    await store.send(.authorizeButtonClicked(.accessibility))
  }

  @Test
  func `sections with required and optional permissions`() {
    let requiredPermission = Permission(kind: .accessibility, required: true, reason: "required")
    let optionalPermission = Permission(kind: .recording, required: false, reason: "optional")

    let store = TestStore(initialState: PermissionsFeature.State(permissions: [requiredPermission, optionalPermission])) {
      PermissionsFeature()
    }

    #expect(store.state.sections == [
      PermissionsFeature.Section(label: "Required", permissions: [PermissionRowState(permission: requiredPermission)]),
      PermissionsFeature.Section(label: "Recommended", permissions: [PermissionRowState(permission: optionalPermission)]),
    ])
  }

  @Test
  func `sections with only required permissions`() {
    let requiredPermission1 = Permission(kind: .accessibility, required: true, reason: "required1")
    let requiredPermission2 = Permission(kind: .recording, required: true, reason: "required2")

    let store = TestStore(initialState: PermissionsFeature.State(permissions: [requiredPermission1, requiredPermission2])) {
      PermissionsFeature()
    }

    #expect(store.state.sections == [
      PermissionsFeature.Section(
        label: "Required",
        permissions: [
          PermissionRowState(permission: requiredPermission1),
          PermissionRowState(permission: requiredPermission2),
        ],
      )
    ])
  }

  @Test
  func `sections with only optional permissions`() {
    let optionalPermission1 = Permission(kind: .accessibility, required: false, reason: "optional1")
    let optionalPermission2 = Permission(kind: .recording, required: false, reason: "optional2")

    let store = TestStore(initialState: PermissionsFeature.State(permissions: [optionalPermission1, optionalPermission2])) {
      PermissionsFeature()
    }

    #expect(store.state.sections == [
      PermissionsFeature.Section(
        label: "Recommended",
        permissions: [
          PermissionRowState(permission: optionalPermission1),
          PermissionRowState(permission: optionalPermission2),
        ],
      )
    ])
  }

  @Test
  func `allGranted(), with no required permissions, should return true`() {
    let optionalPermission = Permission(kind: .accessibility, required: false, reason: "optional")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [optionalPermission])) {
      PermissionsFeature()
    }

    #expect(store.state.allGranted())
  }

  @Test
  func `allGranted(), with no permissions, should return true`() {
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [])) {
      PermissionsFeature()
    }

    #expect(store.state.allGranted())
  }

  @Test
  func `allGranted(), should return true when all required permissions are granted`() async {
    let requiredPermission = Permission(kind: .accessibility, required: true, reason: "required")

    let store = TestStore(initialState: PermissionsFeature.State(permissions: [requiredPermission])) {
      PermissionsFeature()
    } withDependencies: { d in
      let mockClient = AXClientMock()
      mockClient._isProcessTrusted = {
        true
      }
      mockClient._isProcessTrustedWithOptions = { _ in
        true
      }
      d.axClient = mockClient
    }

    // Initially denied
    #expect(!store.state.allGranted())

    // Grant the required permission
    await store.send(.onAppear) {
      $0.permissions[id: requiredPermission.id]?.permission.status = .granted
    }

    #expect(store.state.allGranted())
  }

  @Test
  func `popoverToggled, should show the popover`() async {
    let permission = Permission.accessibility(reason: "test")
    let store = TestStore(initialState: PermissionsFeature.State(permissions: [permission])) {
      PermissionsFeature()
    }

    await store.send(.popoverToggled(permission.id, true)) {
      $0.permissions[id: permission.id]?.isInfoPopoverShown = true
    }
  }

  @Test
  func `popoverToggled, should hide the popover`() async {
    let permission = Permission.accessibility(reason: "test")
    let store = TestStore(
      initialState: PermissionsFeature.State(
        permissions: [PermissionRowState(permission: permission, isInfoPopoverShown: true)]
      )
    ) {
      PermissionsFeature()
    }

    await store.send(.popoverToggled(permission.id, false)) {
      $0.permissions[id: permission.id]?.isInfoPopoverShown = false
    }
  }

  @Test
  func `popoverToggled, with invalid id, should do nothing`() async {
    let store = TestStore(initialState: PermissionsFeature.State()) {
      PermissionsFeature()
    }

    await store.send(.popoverToggled(.accessibility, true))
  }
}
