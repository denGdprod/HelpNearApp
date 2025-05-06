import 'package:cloud_firestore/cloud_firestore.dart';
import 'medical_data_model.dart';

class UserProfile {
  final String name;
  final String surname;
  final String phone;
  final String? email;
  final DateTime birthday;
  final String? photoUrl;
  final bool profileCreated;
  final int helpCount;
  final int receivedHelpCount;
  final String role;
  final Timestamp? createdAt;
  final String? medicalDataId;

  UserProfile({
    required this.name,
    required this.surname,
    required this.phone,
    this.email,
    required this.birthday,
    this.photoUrl,
    this.profileCreated = true,
    this.helpCount = 0,
    this.receivedHelpCount = 0,
    this.role = 'user',
    this.createdAt,
    this.medicalDataId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'phone': phone,
      'email_address': email,
      'birthday': birthday,
      'photoUrl': photoUrl,
      'profileCreated': profileCreated,
      'help_count': helpCount,
      'received_help_count': receivedHelpCount,
      'role': role,
      'created_at': FieldValue.serverTimestamp(),
      'medical_data_id': medicalDataId,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email_address'],
      birthday: (json['birthday'] as Timestamp).toDate(),
      photoUrl: json['photoUrl'],
      profileCreated: json['profileCreated'] ?? false,
      helpCount: json['help_count'] ?? 0,
      receivedHelpCount: json['received_help_count'] ?? 0,
      role: json['role'] ?? 'user',
      createdAt: json['created_at'],
      medicalDataId: json['medical_data_id'],
    );
  }
}
