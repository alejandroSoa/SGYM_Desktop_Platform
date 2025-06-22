class User {
  final int id;
  final int roleId;
  final String email;
  final String password;
  final bool isActive;
  final String? lastAccess;

  User({
    required this.id,
    required this.roleId,
    required this.email,
    required this.password,
    required this.isActive,
    this.lastAccess,
  });
}

typedef UserList = List<User>;