class Permission {
  final int id;
  final String name;
  final String? description;

  Permission({
    required this.id, 
    required this.name, 
    this.description
  });
}

typedef PermissionList = List<Permission>;