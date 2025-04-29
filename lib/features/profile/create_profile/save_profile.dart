import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpnear_app/data/models/user_model.dart';

Future<void> saveUserProfile({
  required String name,
  required String surname,
  required String phone,
  required DateTime birthday,
  String? photoUrl,
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userProfile = UserProfile(
      name: name,
      surname: surname,
      phone: '79$phone',
      email: user.email,
      birthday: birthday,
      photoUrl: photoUrl,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toJson());
    } catch (e) {
      print("Ошибка при сохранении профиля: $e");
      throw Exception("Ошибка при сохранении профиля");
    }
  } else {
    throw Exception("Пользователь не авторизован");
  }
}
