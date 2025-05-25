class HelpRequest {
  final String id; // Уникальный идентификатор запроса
  final String userId; // Идентификатор пользователя
  final String? incidentAddress;
  final double latitude;
  final double longitude;
  final bool hasInjured;
  final bool isRequesterVictim;
  final String incidentType; // например: 'fire', 'accident', 'medical', 'crime'
  final String description;
  final double priority; // от 0.0 до 1.0
  final DateTime createdAt;
  final DateTime? closedAt;
  final String status; // например: 'open', 'in_progress', 'closed'

  HelpRequest({
    required this.id,
    required this.userId,
    required this.incidentAddress,
    required this.latitude,
    required this.longitude,
    required this.hasInjured,
    required this.isRequesterVictim,
    required this.incidentType,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.closedAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'incident_address': incidentAddress,
      'latitude': latitude,
      'longitude': longitude,
      'has_injured': hasInjured,
      'is_requester_victim': isRequesterVictim,
      'incident_type': incidentType,
      'description': description,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'status': status,
    };
  }

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    return HelpRequest(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      incidentAddress: json['incident_address'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      hasInjured: json['has_injured'] ?? false,
      isRequesterVictim: json['is_requester_victim'] ?? false,
      incidentType: json['incident_type'] ?? 'other',
      description: json['description'] ?? '',
      priority: (json['priority'] ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'])
          : null,
      status: json['status'] ?? 'open',
    );
  }

  factory HelpRequest.empty() {
    return HelpRequest(
      id: '',
      userId: '',
      incidentAddress: null,
      latitude: 0.0,
      longitude: 0.0,
      hasInjured: false,
      isRequesterVictim: false,
      incidentType: 'other',
      description: '',
      priority: 0.0,
      createdAt: DateTime.now(),
      closedAt: null,
      status: 'open',
    );
  }

  HelpRequest copyWith({
    String? id,
    String? userId,
    String? incidentAddress,
    double? latitude,
    double? longitude,
    bool? hasInjured,
    bool? isRequesterVictim,
    String? incidentType,
    String? description,
    double? priority,
    DateTime? createdAt,
    DateTime? closedAt,
    String? status,
  }) {
    return HelpRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      incidentAddress: incidentAddress ?? this.incidentAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasInjured: hasInjured ?? this.hasInjured,
      isRequesterVictim: isRequesterVictim ?? this.isRequesterVictim,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      status: status ?? this.status,
    );
  }
}
