/// Interfaz para el request de envío de notificaciones
class NotificationRequest {
  final String channel; // "email" o "push"
  final String? subject; // Obligatorio si channel = "email"
  final String message;
  final List<int> userIds;
  final NotificationData? data;

  NotificationRequest({
    required this.channel,
    this.subject,
    required this.message,
    required this.userIds,
    this.data,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'channel': channel,
      'message': message,
      'user_ids': userIds,
    };

    if (subject != null) {
      json['subject'] = subject;
    }

    if (data != null) {
      json['data'] = data!.toJson();
    }

    return json;
  }
}

/// Datos adicionales para notificaciones push
class NotificationData {
  final String? type;
  final Map<String, dynamic>? metadata;

  NotificationData({this.type, this.metadata});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (type != null) {
      json['type'] = type;
    }

    if (metadata != null) {
      json['metadata'] = metadata;
    }

    return json;
  }
}

/// Respuesta del servicio de envío de notificaciones
class NotificationResponse {
  final String status;
  final NotificationResponseData data;
  final String msg;

  NotificationResponse({
    required this.status,
    required this.data,
    required this.msg,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'],
      data: NotificationResponseData.fromJson(json['data']),
      msg: json['msg'],
    );
  }
}

/// Datos de la respuesta de notificaciones
class NotificationResponseData {
  final int notificationsSent;
  final String channel;

  NotificationResponseData({
    required this.notificationsSent,
    required this.channel,
  });

  factory NotificationResponseData.fromJson(Map<String, dynamic> json) {
    return NotificationResponseData(
      notificationsSent: json['notifications_sent'],
      channel: json['channel'],
    );
  }
}
