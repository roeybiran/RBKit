import Testing

@testable import PermissionsKit

struct PermissionStateTests {
  @Test
  func `init should set permission`() {
    let permission = Permission.accessibility(reason: "test")
    let state = PermissionRowState(permission: permission)

    #expect(state.permission == permission)
  }

  @Test
  func `id should match permission id`() {
    let permission = Permission.accessibility(reason: "test")
    let state = PermissionRowState(permission: permission)

    #expect(state.id == permission.id)
  }

  @Test
  func `is auth button disabled when in progress should be true`() {
    let state = PermissionRowState(
      permission: Permission(kind: .accessibility, reason: "test", status: .inProgress)
    )

    #expect(state.isAuthButtonDisabled)
  }

  @Test
  func `is auth button disabled when granted should be true`() {
    let state = PermissionRowState(
      permission: Permission(kind: .accessibility, reason: "foo", status: .granted)
    )

    #expect(state.isAuthButtonDisabled)
  }

  @Test
  func `is auth button disabled when denied should be false`() {
    let state = PermissionRowState(
      permission: Permission(kind: .accessibility, reason: "foo", status: .denied)
    )

    #expect(!state.isAuthButtonDisabled)
  }

  @Test
  func `is auth button disabled when no status should be false`() {
    let state = PermissionRowState(
      permission: Permission(kind: .accessibility, reason: "foo", status: nil)
    )

    #expect(!state.isAuthButtonDisabled)
  }
}
