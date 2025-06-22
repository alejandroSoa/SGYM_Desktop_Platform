class Membership {
  final int id;
  final String name;
  final int durationDays;
  final double price;

  Membership({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
  });
}

typedef MembershipList = List<Membership>;