class UserAddress {
  final int id;
  final int profileId;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  UserAddress({
    required this.id,
    required this.profileId,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });
}

typedef UserAddressList = List<UserAddress>;