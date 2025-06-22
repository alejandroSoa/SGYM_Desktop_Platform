class Food {
  final int id;
  final String name;
  final double grams;
  final double calories;
  final String? otherInfo;

  Food({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    this.otherInfo,
  });
}

typedef FoodList = List<Food>;