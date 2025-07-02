class User {
  final int id;
  final int roleId;
  final String email;
  final String? password;
  final bool isActive;
  final String? lastAccess;

  User({
    required this.id,
    required this.roleId,
    required this.email,
    this.password,
    required this.isActive,
    this.lastAccess,
  });

  // Factory para mapear tanto 'role_id' como 'roleId'
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? json['roleId'] ?? 0,
      email: json['email'] ?? '',
      password: json['password'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      lastAccess: json['last_access'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role_id': roleId,
      'is_active': isActive,
      'last_access': lastAccess,
    };
  }
}

typedef UserList = List<User>;