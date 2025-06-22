class PaymentMethod {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
  });
}

typedef PaymentMethodList = List<PaymentMethod>;