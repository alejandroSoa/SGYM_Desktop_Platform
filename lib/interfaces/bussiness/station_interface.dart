class Station {
  final int id;
  final String stationId;
  final String stationToken;
  final String type;
  final String location;
  final String firmwareVersion;
  final String status;
  final int userIn;
  final String hardwareId;

  Station({
    required this.id,
    required this.stationId,
    required this.stationToken,
    required this.type,
    required this.location,
    required this.firmwareVersion,
    required this.status,
    required this.userIn,
    required this.hardwareId,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      stationId: json['stationId'],
      stationToken: json['stationToken'],
      type: json['type'],
      location: json['location'],
      firmwareVersion: json['firmwareVersion'],
      status: json['status'],
      userIn: json['userIn'],
      hardwareId: json['hardwareId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationId': stationId,
      'stationToken': stationToken,
      'type': type,
      'location': location,
      'firmwareVersion': firmwareVersion,
      'status': status,
      'userIn': userIn,
      'hardwareId': hardwareId,
    };
  }
}
