class Exercise {
  final int id;
  final String name;
  final String description;
  final EquipmentType equipmentType;
  final String videoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.equipmentType,
    required this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      equipmentType: _parseEquipmentType(
        json['equipmentType'] ?? json['equipment_type'],
      ),
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'equipment_type': equipmentType.value,
      'video_url': videoUrl,
    };
  }

  static EquipmentType _parseEquipmentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'machine':
        return EquipmentType.machine;
      case 'dumbbell':
        return EquipmentType.dumbbell;
      case 'other':
        return EquipmentType.other;
      default:
        return EquipmentType.other;
    }
  }
}

enum EquipmentType {
  machine('machine'),
  dumbbell('dumbbell'),
  other('other');

  const EquipmentType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case EquipmentType.machine:
        return 'Máquina';
      case EquipmentType.dumbbell:
        return 'Mancuernas';
      case EquipmentType.other:
        return 'Otro';
    }
  }
}
