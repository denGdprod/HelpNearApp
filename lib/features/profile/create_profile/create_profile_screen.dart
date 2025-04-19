import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'upload_photo.dart';
import 'save_profile.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
class CreateProfileScreen extends StatefulWidget {
  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _photoUploader = ProfilePhotoUploader();
  DateTime? _selectedBirthday;
  File? _pickedImage;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+7 (9##) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

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
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
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
          phone: _phoneMaskFormatter.getUnmaskedText(), // Чистый номер
          birthday: _selectedBirthday!,
          photoUrl: photoUrl,
        );

      Future.delayed(Duration(seconds: 1), () {
        context.goNamed('map');
      });
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
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _pickedImage != null ? FileImage(_pickedImage!) : null,
                  child: _pickedImage == null
                      ? Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя'),
                validator: (value) =>
                    value!.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Фамилия'),
                validator: (value) =>
                    value!.isEmpty ? 'Введите фамилию' : null,
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
                        ? 'Дата рождения: ${DateFormat('dd.MM.yyyy').format(_selectedBirthday!)}' // Форматируем дату
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
