class Profile {
  final int userId;
  final String fullName;
  final String? phone;
  final String birthDate;
  final String gender;
  final String? photoUrl;

  Profile({
    required this.userId,
    required this.fullName,
    this.phone,
    required this.birthDate,
    required this.gender,
    this.photoUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['user_id'],
      fullName: json['full_name'],
      phone: json['phone'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      photoUrl: json['photo_url'],
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      'photo_url': photoUrl,
    };
  }
}