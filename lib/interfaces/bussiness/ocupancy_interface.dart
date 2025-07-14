class Occupancy {
  final String recordedAt;
  final String level;
  final int? peopleCount;

  Occupancy({
    required this.recordedAt,
    required this.level,
    this.peopleCount,
  });

  factory Occupancy.fromJson(Map<String, dynamic> json) {
    return Occupancy(
      recordedAt: json['recorded_at'],
      level: json['level'],
      peopleCount: json['people_count'] != null
          ? (json['people_count'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recorded_at': recordedAt,
      'level': level,
      'people_count': peopleCount,
    };
  }
}

typedef OccupancyList = List<Occupancy>;