class Diet {
  final int id;
  final String name;
  final String? description;

  Diet({
    required this.id,
    required this.name,
    this.description,
  });

  factory Diet.fromJson(Map<String, dynamic> json) {
    return Diet(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

typedef DietList = List<Diet>;