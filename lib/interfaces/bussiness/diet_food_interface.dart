class DietFood {
  final int id;
  final int foodId;
  final int dietId;

  DietFood({
    required this.id,
    required this.foodId,
    required this.dietId,
  });
}

typedef DietFoodList = List<DietFood>;