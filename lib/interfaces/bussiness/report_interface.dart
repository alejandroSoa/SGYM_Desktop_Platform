class ReportAccess {
  final bool access;
  final String date;
  final String startTime;
  final String endTime;
  final int userId;

  ReportAccess({
    required this.access,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.userId,
  });

  factory ReportAccess.fromJson(Map<String, dynamic> json) {
    return ReportAccess(
      access: json['access'] ?? false,
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'userId': userId,
    };
  }
}
