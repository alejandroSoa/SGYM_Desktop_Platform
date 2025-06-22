class TrainerSchedule {
  final int id;
  final int userId;
  final int trainerId;
  final String startTime;
  final String endTime;

  TrainerSchedule({
    required this.id,
    required this.userId,
    required this.trainerId,
    required this.startTime,
    required this.endTime,
  });
}

typedef TrainerScheduleList = List<TrainerSchedule>;