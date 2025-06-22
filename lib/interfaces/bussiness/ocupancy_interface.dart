class Occupancy {
  final String recordedAt;
  final String level;
  final int? peopleCount;

  Occupancy({
    required this.recordedAt,
    required this.level,
    this.peopleCount,
  });
}

typedef OccupancyList = List<Occupancy>;