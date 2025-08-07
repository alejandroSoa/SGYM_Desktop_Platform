class Schedule {
  final int id;
  final int userId;
  final String startTime;
  final String endTime;

  Schedule({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: (json['user_id'] ?? json['userId']) is int
          ? (json['user_id'] ?? json['userId'])
          : int.tryParse((json['user_id'] ?? json['userId'])?.toString() ?? '') ?? 0,
      startTime: (json['start_time'] ?? json['startTime'])?.toString() ?? '',
      endTime: (json['end_time'] ?? json['endTime'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

typedef ScheduleList = List<Schedule>;