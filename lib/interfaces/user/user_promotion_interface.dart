class UserPromotion {
  final int id;
  final int promotionId;
  final int userId;
  final String appliedAt;
  final String expiredAt;

  UserPromotion({
    required this.id,
    required this.promotionId,
    required this.userId,
    required this.appliedAt,
    required this.expiredAt,
  });
}

typedef UserPromotionList = List<UserPromotion>;