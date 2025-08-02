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
<<<<<<< HEAD
      id: json['id'] as int? ?? 0,
      exerciseId: json['exercise_id'] as int? ?? 0,
      routineId: json['routine_id'] as int? ?? 0,
=======
      id: json['id'],
      exerciseId: json['exercise_id'],
      routineId: json['routine_id'],
>>>>>>> f0f3cce72a7416390a4b77773120993523875853
    );
  }

  Map<String, dynamic> toJson() {
<<<<<<< HEAD
    return {'id': id, 'exercise_id': exerciseId, 'routine_id': routineId};
=======
    return {
      'id': id,
      'exercise_id': exerciseId,
      'routine_id': routineId,
    };
>>>>>>> f0f3cce72a7416390a4b77773120993523875853
  }
}

typedef RoutineExerciseList = List<RoutineExercise>;
