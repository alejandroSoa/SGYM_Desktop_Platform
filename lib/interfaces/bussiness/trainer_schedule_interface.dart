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
      userId: json['userId'],
      trainerId: json['trainerId'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'trainerId': trainerId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

typedef TrainerScheduleList = List<TrainerSchedule>;