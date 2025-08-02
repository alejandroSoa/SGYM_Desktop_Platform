class Routine {
  final int id;
  final String day;
  final String name;
  final String? description;
  final int userId;

  Routine({
    required this.id,
    required this.day,
    required this.name,
    this.description,
    required this.userId,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as int? ?? 0,
      day: json['day'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'name': name,
      'description': description,
      'userId': userId,
    };
  }
}

typedef RoutineList = List<Routine>;
