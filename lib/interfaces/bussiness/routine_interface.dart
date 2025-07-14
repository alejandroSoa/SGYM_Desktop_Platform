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

typedef RoutineList = List<Routine>;