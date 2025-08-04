class DietFood {
  final int id;
  final int foodId;
  final int dietId;

  DietFood({
    required this.id,
    required this.foodId,
    required this.dietId,
  });

  factory DietFood.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    return DietFood(
      id: parseInt(json['id']),
      foodId: parseInt(json['food_id'] ?? json['foodId']),
      dietId: parseInt(json['diet_id'] ?? json['dietId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_id': foodId,
      'diet_id': dietId,
    };
  }
}

typedef DietFoodList = List<DietFood>;