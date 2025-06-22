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
}

typedef RoutineList = List<Routine>;