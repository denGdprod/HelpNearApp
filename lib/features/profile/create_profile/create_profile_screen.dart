import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'upload_photo.dart';
import 'save_profile.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:helpnear_app/core/utils/auth_state_notifier.dart';
import 'package:provider/provider.dart';
import 'package:helpnear_app/features/profile/image_cropper_service.dart'; // Импортируем для обрезки

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class CircleClipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) {
      return Path()
        ..addOval(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2));
    }

    @override
    bool shouldReclip(CustomClipper<Path> oldClipper) {
      return false;
    }
  }
class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUploader = ProfilePhotoUploader();
  DateTime? _selectedBirthday;
  final _imageCropperService = ImageCropperService();
  File? _pickedImage;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (9##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request(); // Android 13+
      if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Разрешите доступ ко всем фото в настройках'),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedBirthday = date;
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await _imageCropperService.pickAndCropImage(context);
    if (image != null && mounted) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _selectedBirthday != null) {
      try {
        String? photoUrl;
        if (_pickedImage != null) {
          photoUrl = await _photoUploader.uploadFile(_pickedImage!, context);
        }

        await saveUserProfile(
          name: _nameController.text,
          surname: _surnameController.text,
          phone: _phoneMaskFormatter.getUnmaskedText(),
          birthday: _selectedBirthday!,
          photoUrl: photoUrl,
        );
        await context.read<AuthStateNotifier>().checkProfileCreated();
        context.goNamed('map');
      } catch (e) {
        print("Ошибка при сохранении профиля: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ошибка при сохранении профиля")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Пожалуйста, заполните все поля и выберите дату рождения")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создание профиля')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias, // Важно: обрезает содержимое по кругу
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            width: 200,
                            height: 200,
                          )
                        : const Icon(Icons.add_a_photo, size: 60, color: Colors.grey),
                  ),
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя'),
                validator: (value) => value!.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Фамилия'),
                validator: (value) => value!.isEmpty ? 'Введите фамилию' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  hintText: '+7 (9__) ___-__-__',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneMaskFormatter],
                validator: (value) {
                  if (value == null || !_phoneMaskFormatter.isFill()) {
                    return 'Введите корректный номер';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _selectedBirthday != null
                        ? 'Дата рождения: ${DateFormat('dd.MM.yyyy').format(_selectedBirthday!)}'
                        : 'Выберите дату рождения',
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Выбрать'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Сохранить профиль'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
