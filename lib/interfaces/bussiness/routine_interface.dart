class Routine {
  final int id;
  final String name;
  final String? description;
  final int? userId;

  Routine({
    required this.id,
    required this.name,
    this.description,
    this.userId,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userId: json['userId'], // Puede venir null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
    };
  }
}

typedef RoutineList = List<Routine>;
