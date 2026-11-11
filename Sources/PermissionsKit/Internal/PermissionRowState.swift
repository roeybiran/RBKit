// MARK: - PermissionRowState

@dynamicMemberLookup
struct PermissionRowState: Equatable, Identifiable {
  var permission: Permission
  var isInfoPopoverShown = false

  var isAuthButtonDisabled: Bool {
    permission.status == .inProgress || permission.status == .granted
  }

  var id: Permission.ID {
    permission.id
  }

  subscript<T>(dynamicMember keyPath: KeyPath<Permission, T>) -> T {
    permission[keyPath: keyPath]
  }
}

extension PermissionRowState {
  init(permission: Permission) {
    self.permission = permission
  }
}
