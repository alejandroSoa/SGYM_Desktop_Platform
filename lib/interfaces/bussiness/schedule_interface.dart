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
}

typedef ScheduleList = List<Schedule>;