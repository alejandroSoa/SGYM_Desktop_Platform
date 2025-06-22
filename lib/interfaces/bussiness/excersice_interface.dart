class Exercise {
  final int id;
  final String name;
  final String? description;
  final String equipmentType;
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.equipmentType,
    this.videoUrl,
  });
}

typedef ExerciseList = List<Exercise>;