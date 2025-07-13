class QrCode {
  final int userId;
  final String qrToken;
  final String qrImageBase64;

  QrCode({
    required this.userId,
    required this.qrToken,
    required this.qrImageBase64,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      userId: json['user_id'],
      qrToken: json['qr_token'],
      qrImageBase64: json['qr_image_base64'],
    );
  }
}