import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProfilePhotoUploader {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  Future<String?> uploadFile(File file, BuildContext context) async {
    try {
      final String fileName = _uuid.v4(); // генерируем уникальное имя
      final Reference storageRef = _storage.ref().child('profile_photos/$fileName.jpg');
      final UploadTask uploadTask = storageRef.putFile(file);

      // Ждём завершения загрузки
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Успешно
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Фото успешно загружено')),
      );

      return downloadUrl;
    } catch (e) {
      // Ошибка загрузки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке фото: $e')),
      );
      return null;
    }
  }
}
