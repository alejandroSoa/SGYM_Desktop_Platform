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
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    return Food(
      id: json['id'],
      name: json['name'],
      grams: parseDouble(json['grams']),
      calories: parseDouble(json['calories']),
      otherInfo: json['otherInfo'] ?? json['other_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grams': grams,
      'calories': calories,
      'otherInfo': otherInfo,
    };
  }
}

typedef FoodList = List<Food>;