class UserQrCode {
  final int userId;
  final String qrToken;
  final String createdAt;
  final String updatedAt;

  UserQrCode({
    required this.userId,
    required this.qrToken,
    required this.createdAt,
    required this.updatedAt,
  });
}

typedef UserQrCodeList = List<UserQrCode>;