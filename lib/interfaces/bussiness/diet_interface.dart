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
}

typedef DietList = List<Diet>;