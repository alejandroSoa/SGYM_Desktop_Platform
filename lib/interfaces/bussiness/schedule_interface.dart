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
      id: json['id'],
      userId: json['user_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
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