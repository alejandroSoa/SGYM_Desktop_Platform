class FileData {
  final int id;
  final String fileName;
  final String mimeType;
  final String url;
  final String type;
  final int? relatedId;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FileData({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.url,
    required this.type,
    this.relatedId,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      id: json['id'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      url: json['url'],
      type: json['type'],
      relatedId: json['related_id'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'mime_type': mimeType,
      'url': url,
      'type': type,
      'related_id': relatedId,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class FileUploadRequest {
  final String type;
  final int? relatedId;
  final String? description;

  FileUploadRequest({required this.type, this.relatedId, this.description});

  Map<String, dynamic> toJson() {
    return {'type': type, 'related_id': relatedId, 'description': description};
  }
}

class FileListResponse {
  final String status;
  final List<FileData> data;
  final String msg;

  FileListResponse({
    required this.status,
    required this.data,
    required this.msg,
  });

  factory FileListResponse.fromJson(Map<String, dynamic> json) {
    return FileListResponse(
      status: json['status'],
      data: (json['data'] as List)
          .map((item) => FileData.fromJson(item))
          .toList(),
      msg: json['msg'],
    );
  }
}

class FileUploadResponse {
  final String status;
  final FileData data;
  final String msg;

  FileUploadResponse({
    required this.status,
    required this.data,
    required this.msg,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      status: json['status'],
      data: FileData.fromJson(json['data']),
      msg: json['msg'],
    );
  }
}

class FileDeleteResponse {
  final String status;
  final Map<String, dynamic> data;
  final String msg;

  FileDeleteResponse({
    required this.status,
    required this.data,
    required this.msg,
  });

  factory FileDeleteResponse.fromJson(Map<String, dynamic> json) {
    return FileDeleteResponse(
      status: json['status'],
      data: json['data'],
      msg: json['msg'],
    );
  }
}
