class Diet {
  final int id;
  final String day;
  final String name;
  final String? description;
  final int userId;

  Diet({
    required this.id,
    required this.day,
    required this.name,
    this.description,
    required this.userId,
  });

  factory Diet.fromJson(Map<String, dynamic> json) {
    return Diet(
      id: json['id'],
      day: json['day'],
      name: json['name'],
      description: json['description'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'name': name,
      'description': description,
      'user_id': userId,
    };
  }
}

typedef DietList = List<Diet>;