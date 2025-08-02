
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      roleId: json['roleId'] ?? json['role_id'],
      email: json['email'],
      password: json['password'],
      isActive: (json['isActive'] ?? json['is_active']) == 1 || (json['isActive'] ?? json['is_active']) == true,
      lastAccess: json['lastAccess'] ?? json['last_access'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'email': email,
      'password': password,
      'isActive': isActive ? 1 : 0,
      'lastAccess': lastAccess,
    };
  }
}

typedef UserList = List<User>;