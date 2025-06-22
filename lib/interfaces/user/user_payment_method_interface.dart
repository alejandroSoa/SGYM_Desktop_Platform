class UserPaymentMethod {
  final int id;
  final int userId;
  final String customerId;
  final String paymentMethodId;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;

  UserPaymentMethod({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.paymentMethodId,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
}

typedef UserPaymentMethodList = List<UserPaymentMethod>;