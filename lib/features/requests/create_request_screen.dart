import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:helpnear_app/data/models/help_request.dart';

class HelpRequestScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const HelpRequestScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HelpRequestScreen> createState() => _HelpRequestScreenState();
}

class _HelpRequestScreenState extends State<HelpRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _incidentType = 'medical';
  bool _isRequesterVictim = false;
  double _priority = 0.5;
  late double _latitude;
  late double _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.latitude;
    _longitude = widget.longitude;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String buildAddress() {
    final parts = <String>[];
    final street = _streetController.text.trim();
    final house = _houseController.text.trim();
    final apartment = _apartmentController.text.trim();

    if (street.isNotEmpty) parts.add(street);
    if (house.isNotEmpty) parts.add('д. $house');
    if (apartment.isNotEmpty) parts.add('кв. $apartment');

    return parts.join(', ');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final address = buildAddress();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите адрес полностью')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы не авторизованы')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final request = HelpRequest(
      id: const Uuid().v4(),
      userId: user.uid,
      incidentAddress: address,
      latitude: _latitude,
      longitude: _longitude,
      hasInjured: !_isRequesterVictim,
      isRequesterVictim: _isRequesterVictim,
      incidentType: _incidentType,
      description: _descriptionController.text,
      priority: _priority,
      createdAt: DateTime.now(),
      closedAt: null,
      status: 'open',
    );

    try {
      final firestore = FirebaseFirestore.instance;

      // Запись в глобальную коллекцию
      await firestore
          .collection('help_requests')
          .doc(request.id)
          .set(request.toJson());

      // Запись в подколлекцию пользователя
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('help_requests')
          .doc(request.id)
          .set(request.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запрос отправлен')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Ошибка сохранения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при отправке запроса')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coordsText =
        'Координаты: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Новый запрос о помощи')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Улица (необязательно)',
                        helperText: 'Заполнение адреса поможет быстрее вас найти',
                      ),
                      validator: (value) => null, // поле не обязательно
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _houseController,
                      decoration: const InputDecoration(
                        labelText: 'Номер дома (необязательно)',
                      ),
                      validator: (value) => null, // необязательно
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _apartmentController,
                      decoration: const InputDecoration(labelText: 'Квартира (необязательно)'),
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 8),
                    Text(coordsText,
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _incidentType,
                      items: const [
                        DropdownMenuItem(
                            value: 'medical', child: Text('Проблемы со здоровьем')),
                        DropdownMenuItem(
                            value: 'fire', child: Text('Пожар или запах гари')),
                        DropdownMenuItem(
                            value: 'accident',
                            child: Text('Дорожно-транспортное происшествие')),
                        DropdownMenuItem(
                            value: 'crime',
                            child: Text('Подозрительное поведение или конфликт')),
                        DropdownMenuItem(
                            value: 'locked_out',
                            child: Text('Заклинило дверь / нет доступа в жильё')),
                        DropdownMenuItem(
                            value: 'home_emergency',
                            child: Text('Протечка, затопление или авария в доме')),
                        DropdownMenuItem(
                            value: 'electricity', child: Text('Проблемы с электричеством')),
                        DropdownMenuItem(value: 'other', child: Text('Другое происшествие')),
                      ],
                      onChanged: (val) => setState(() => _incidentType = val!),
                      decoration:
                          const InputDecoration(labelText: 'Тип происшествия'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Кто пострадал?', style: TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile<bool>(
                      title: const Text('Я — пострадавший'),
                      value: false,
                      groupValue: _isRequesterVictim,
                      onChanged: (val) => setState(() => _isRequesterVictim = val!),
                    ),
                    RadioListTile<bool>(
                      title: const Text('Другой человек'),
                      value: true,
                      groupValue: _isRequesterVictim,
                      onChanged: (val) => setState(() => _isRequesterVictim = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Описание'),
                      maxLines: 3,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Введите описание' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Оцените срочность запроса',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _priority,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      label: 'Приоритет: ${(_priority * 10).round()}',
                      onChanged: (value) => setState(() => _priority = value),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Отправить запрос'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
