class PaymentRequest {
  final int id;
  final int userId;
  final int paymentMethodId;
  final String? externalReference;
  final double amount;
  final String currency;
  final String status;
  final String? description;
  final String? metadata;
  final String createdAt;
  final String updatedAt;

  PaymentRequest({
    required this.id,
    required this.userId,
    required this.paymentMethodId,
    this.externalReference,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });
}

typedef PaymentRequestList = List<PaymentRequest>;