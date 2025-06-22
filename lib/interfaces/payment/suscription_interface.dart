class Subscription {
  final int id;
  final int userId;
  final int membershipId;
  final String startDate;
  final String endDate;
  final String status;
  final bool isRenewable;
  final String? canceledAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.membershipId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isRenewable,
    this.canceledAt,
  });
}

typedef SubscriptionList = List<Subscription>;