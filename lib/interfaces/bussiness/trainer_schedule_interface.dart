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

  factory TrainerSchedule.fromJson(Map<String, dynamic> json) {
    return TrainerSchedule(
      id: json['id'],
      userId: json['user_id'],
      trainerId: json['trainer_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trainer_id': trainerId,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

typedef TrainerScheduleList = List<TrainerSchedule>;