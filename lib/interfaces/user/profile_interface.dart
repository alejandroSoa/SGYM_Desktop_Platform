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

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      fullName: json['full_name'],
      phone: json['phone'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      photoUrl: json['photo_url'],
    );
  }
}