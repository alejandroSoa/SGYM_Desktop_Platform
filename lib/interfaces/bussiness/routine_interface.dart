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
<<<<<<< HEAD
      id: json['id'] as int? ?? 0,
      day: json['day'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      userId: json['userId'] as int? ?? 0,
=======
      id: json['id'],
      day: json['day'],
      name: json['name'],
      description: json['description'],
      userId: json['user_id'],
>>>>>>> f0f3cce72a7416390a4b77773120993523875853
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'name': name,
      'description': description,
<<<<<<< HEAD
      'userId': userId,
=======
      'user_id': userId,
>>>>>>> f0f3cce72a7416390a4b77773120993523875853
    };
  }
}

typedef RoutineList = List<Routine>;
