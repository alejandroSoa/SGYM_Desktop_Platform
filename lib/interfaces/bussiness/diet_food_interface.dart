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
    return DietFood(
      id: json['id'],
      foodId: json['food_id'],
      dietId: json['diet_id'],
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