class QrCode {
  final int userId;
  final String qrToken;
  final String qr_image_base64;

  QrCode({
    required this.userId,
    required this.qrToken,
    required this.qr_image_base64,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      userId: json['user_id'],
      qrToken: json['qr_token'],
      qr_image_base64: json['qr_image_base64'],
    );
  }
}