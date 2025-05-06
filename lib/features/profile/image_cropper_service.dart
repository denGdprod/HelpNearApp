import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropperService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickAndCropImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return null;

      return await _cropImage(File(pickedFile.path), context);
    } catch (e) {
      debugPrint('Image cropping error: $e');
      return null;
    }
  }

  Future<File?> _cropImage(File imageFile, BuildContext context) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Обрезать фото',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: const Color.fromARGB(255, 177, 177, 177),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
          showCropGrid: true,
          hideBottomControls: false,
          activeControlsWidgetColor: Colors.deepPurple,
          dimmedLayerColor: Colors.black.withOpacity(0.7), // Затемнение вне круга
        ),
        IOSUiSettings(
          title: 'Обрезать фото',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          minimumAspectRatio: 1.0,
          cropStyle: CropStyle.circle,
          //showsCroppingGrid: true,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}