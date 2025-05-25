class HelpResponse {
  final String id; // Уникальный ID отклика
  final String helpRequestId; // ID запроса помощи, на который откликаются
  final String responderUserId; // ID пользователя, который откликается
  final String status; // статус отклика: pending, accepted, rejected и т.д.
  final DateTime createdAt; // время создания отклика
  final DateTime? updatedAt; // время последнего обновления отклика (например, изменение статуса)
  final String? comment; // необязательный комментарий откликающегося

  HelpResponse({
    required this.id,
    required this.helpRequestId,
    required this.responderUserId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'help_request_id': helpRequestId,
      'responder_user_id': responderUserId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'comment': comment,
    };
  }

  factory HelpResponse.fromJson(Map<String, dynamic> json) {
    return HelpResponse(
      id: json['id'] ?? '',
      helpRequestId: json['help_request_id'] ?? '',
      responderUserId: json['responder_user_id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      comment: json['comment'],
    );
  }

  factory HelpResponse.empty() {
    return HelpResponse(
      id: '',
      helpRequestId: '',
      responderUserId: '',
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: null,
      comment: null,
    );
  }

  HelpResponse copyWith({
    String? id,
    String? helpRequestId,
    String? responderUserId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? comment,
  }) {
    return HelpResponse(
      id: id ?? this.id,
      helpRequestId: helpRequestId ?? this.helpRequestId,
      responderUserId: responderUserId ?? this.responderUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comment: comment ?? this.comment,
    );
  }
}
