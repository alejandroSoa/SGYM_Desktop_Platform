class Profile {
  final int id;
  final int userId;
  final String fullName;
  final String? phone;
  final String birthDate;
  final String gender;
  final String? photoUrl;

  Profile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.phone,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
  });
}