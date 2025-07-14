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

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      otherInfo: json['other_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grams': grams,
      'calories': calories,
      'other_info': otherInfo,
    };
  }
}

typedef FoodList = List<Food>;