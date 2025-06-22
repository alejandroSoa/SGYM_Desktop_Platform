class RoutineExercise {
  final int id;
  final int exerciseId;
  final int routineId;

  RoutineExercise({
    required this.id,
    required this.exerciseId,
    required this.routineId,
  });
}

typedef RoutineExerciseList = List<RoutineExercise>;