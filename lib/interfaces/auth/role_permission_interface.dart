class RolePermission {
  final int id;
  final int roleId;
  final int permissionId;

  RolePermission({
    required this.id,
    required this.roleId,
    required this.permissionId,
  });
}

typedef RolePermissionList = List<RolePermission>;