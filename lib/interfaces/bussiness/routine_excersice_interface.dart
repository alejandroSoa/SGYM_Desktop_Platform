class RoutineExercise {
  final int id;
  final int exerciseId;
  final int routineId;

  RoutineExercise({
    required this.id,
    required this.exerciseId,
    required this.routineId,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    return RoutineExercise(
      id: json['id'],
      exerciseId: json['exercise_id'],
      routineId: json['routine_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'routine_id': routineId,
    };
  }
}

typedef RoutineExerciseList = List<RoutineExercise>;