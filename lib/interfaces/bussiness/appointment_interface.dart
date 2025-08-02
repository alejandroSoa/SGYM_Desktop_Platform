class TrainerAppointment {
  final int id;
  final int userId;
  final int trainerId;
  final String date;
  final String startTime;
  final String endTime;

  TrainerAppointment({
    required this.id,
    required this.userId,
    required this.trainerId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TrainerAppointment.fromJson(Map<String, dynamic> json) {
    return TrainerAppointment(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      trainerId: json['trainer_id'] as int,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trainer_id': trainerId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class NutritionistAppointment {
  final int id;
  final int userId;
  final int nutritionistId;
  final String date;
  final String startTime;
  final String endTime;

  NutritionistAppointment({
    required this.id,
    required this.userId,
    required this.nutritionistId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory NutritionistAppointment.fromJson(Map<String, dynamic> json) {
    return NutritionistAppointment(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      nutritionistId: json['nutritionist_id'] as int,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nutritionist_id': nutritionistId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

// Para las citas del usuario que incluyen trainer_id pero no nutritionist_id
class UserTrainerAppointment {
  final int id;
  final int trainerId;
  final String date;
  final String startTime;
  final String endTime;

  UserTrainerAppointment({
    required this.id,
    required this.trainerId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory UserTrainerAppointment.fromJson(Map<String, dynamic> json) {
    return UserTrainerAppointment(
      id: json['id'] as int,
      trainerId: json['trainer_id'] as int,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainer_id': trainerId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

typedef TrainerAppointmentList = List<TrainerAppointment>;
typedef NutritionistAppointmentList = List<NutritionistAppointment>;
typedef UserTrainerAppointmentList = List<UserTrainerAppointment>;
