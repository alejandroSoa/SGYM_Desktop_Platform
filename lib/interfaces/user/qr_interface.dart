class QrCode {
  final int userId;
  final String qrToken;
<<<<<<< HEAD
  final String qr_image_base64;
=======
  final String qrImageBase64;
>>>>>>> f0f3cce72a7416390a4b77773120993523875853

  QrCode({
    required this.userId,
    required this.qrToken,
<<<<<<< HEAD
    required this.qr_image_base64,
=======
    required this.qrImageBase64,
>>>>>>> f0f3cce72a7416390a4b77773120993523875853
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      userId: json['user_id'],
      qrToken: json['qr_token'],
<<<<<<< HEAD
      qr_image_base64: json['qr_image_base64'],
=======
      qrImageBase64: json['qr_image_base64'],
>>>>>>> f0f3cce72a7416390a4b77773120993523875853
    );
  }
}