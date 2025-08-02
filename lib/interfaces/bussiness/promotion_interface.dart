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

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      name: json['name'],
      discount: (json['discount'] as num).toDouble(),
      membershipId: json['membership_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discount': discount,
      'membership_id': membershipId,
    };
  }
}

typedef PromotionList = List<Promotion>;