class Payment {
  final int id;
  final int paymentRequestId;
  final int subscriptionId;
  final double amount;
  final String paymentDate;
  final String? concept;
  final String status;
  final String createdAt;

  Payment({
    required this.id,
    required this.paymentRequestId,
    required this.subscriptionId,
    required this.amount,
    required this.paymentDate,
    this.concept,
    required this.status,
    required this.createdAt,
  });
}

typedef PaymentList = List<Payment>;