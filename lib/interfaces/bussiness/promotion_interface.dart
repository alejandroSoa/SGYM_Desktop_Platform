class Promotion {
  final int id;
  final String name;
  final double discount;
  final int membershipId;

  Promotion({
    required this.id,
    required this.name,
    required this.discount,
    required this.membershipId,
  });
}

typedef PromotionList = List<Promotion>;