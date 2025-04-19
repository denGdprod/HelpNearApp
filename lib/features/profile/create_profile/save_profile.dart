import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveUserProfile({
  required String name,
  required String surname,
  required String phone,
  required DateTime birthday,
  String? photoUrl,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'surname': surname,
        'phone': '79$phone',
        'email_adress': user.email,
        'birthday': birthday,
        'photoUrl': photoUrl,
        'profileCreated': true,
        'help_count': 0,
        'received_help_count': 0,
        'role': 'user',
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Ошибка при сохранении профиля: $e");
      throw Exception("Ошибка при сохранении профиля");
    }
  }
}
