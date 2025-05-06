import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpnear_app/data/models/medical_data_model.dart';

class MedicalDataScreen extends StatefulWidget {
  final String? userId;

  const MedicalDataScreen({Key? key, this.userId}) : super(key: key);

  @override
  _MedicalDataScreenState createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _otherDiseasesController = TextEditingController();
  
  MedicalData _medicalData = MedicalData.empty();
  bool _isLoading = false;
  bool _isModified = false;
  bool _isInitialLoad = true;

  final List<String> _genders = ['male', 'female'];
  final List<String> _bloodTypes = [
    'O(I) Rh+', 
    'O(I) Rh−',
    'A(II) Rh+',
    'A(II) Rh−',
    'B(III) Rh+',
    'B(III) Rh−',
    'AB(IV) Rh+',
    'AB(IV) Rh−',
    ];
  final List<String> _disabilities = [
    'hearing', 
    'vision',
    'speech',
    'other'
    ];

  @override
  void initState() {
    super.initState();
    _loadMedicalData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _otherDiseasesController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final uid = widget.userId ?? currentUserId;

    if (uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('metadata')
          .doc('medical_data')
          .get();

      if (doc.exists) {
        _medicalData = MedicalData.fromJson(doc.data()!);
        if (_medicalData.bloodGroup.isEmpty) {
          _medicalData = _medicalData.copyWith(bloodGroup: 'not_selected');
        }
        _weightController.text = _medicalData.weight % 1 == 0 
            ? _medicalData.weight.toInt().toString()
            : _medicalData.weight.toString();
        _otherDiseasesController.text = _medicalData.otherDiseases;
      }
    } catch (e) {
      debugPrint('Error loading medical data: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isInitialLoad = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isModified) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить изменения?'),
        content: const Text('Изменения не будут сохранены. Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoad) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Медицинские данные'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveMedicalData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Пол
          DropdownButtonFormField<String>(
            value: _medicalData.gender,
            onChanged: (newValue) {
              setState(() {
                _medicalData = _medicalData.copyWith(gender: newValue);
                _isModified = true;
              });
            },
            items: _genders.map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender == 'male' ? 'Мужской' : 'Женский'),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: 'Пол'),
          ),

          const SizedBox(height: 16),

          // Группа крови
          DropdownButtonFormField<String>(
            value: _medicalData.bloodGroup == 'not_selected' ? null : _medicalData.bloodGroup,
            hint: const Text('Не выбрано'),
            onChanged: (newValue) {
              setState(() {
                _medicalData = _medicalData.copyWith(
                  bloodGroup: newValue ?? 'not_selected'
                );
                _isModified = true;
              });
            },
            items: [
              // Добавляем отдельный элемент для "Не выбрано"
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Не выбрано'),
              ),
              // Остальные варианты групп крови
              ..._bloodTypes.map((bloodType) {
                return DropdownMenuItem<String>(
                  value: bloodType,
                  child: Text(bloodType),
                );
              }).toList(),
            ],
            decoration: const InputDecoration(labelText: 'Группа крови'),
          ),
          const SizedBox(height: 16),

          // Вес
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Вес (кг)'),
            keyboardType: TextInputType.number,
              onChanged: (value) {
              _isModified = true;
              // Преобразуем введенное значение в double
              final weight = double.tryParse(value.replaceAll(',', '.')) ?? 0;
              _medicalData = _medicalData.copyWith(weight: weight);
            },
          ),

          const SizedBox(height: 16),

          // Инвалидность
          const Text('Инвалидность', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            children: _disabilities.map((disability) {
              return FilterChip(
                label: Text(_disabilityToText(disability)),
                selected: _medicalData.disabilities.contains(disability),
                onSelected: (selected) {
                  setState(() {
                    final newDisabilities = List<String>.from(_medicalData.disabilities);
                    if (selected) {
                      newDisabilities.add(disability);
                    } else {
                      newDisabilities.remove(disability);
                    }
                    _medicalData = _medicalData.copyWith(disabilities: newDisabilities);
                    _isModified = true;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Состояние здоровья
          const Text('Состояние здоровья', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildCheckboxListTile('Беременность', _medicalData.isPregnant, (value) {
            setState(() {
              _medicalData = _medicalData.copyWith(isPregnant: value);
              _isModified = true;
            });
          }),
          _buildCheckboxListTile('Сахарный диабет', _medicalData.hasDiabetes, (value) {
            setState(() {
              _medicalData = _medicalData.copyWith(hasDiabetes: value);
              _isModified = true;
            });
          }),
          _buildCheckboxListTile('Астма', _medicalData.hasAsthma, (value) {
            setState(() {
              _medicalData = _medicalData.copyWith(hasAsthma: value);
              _isModified = true;
            });
          }),
          _buildCheckboxListTile('Сердечная недостаточность', _medicalData.hasHeartFailure, (value) {
            setState(() {
              _medicalData = _medicalData.copyWith(hasHeartFailure: value);
              _isModified = true;
            });
          }),
          _buildCheckboxListTile('Ограниченная подвижность', _medicalData.hasMobilityIssues, (value) {
            setState(() {
              _medicalData = _medicalData.copyWith(hasMobilityIssues: value);
              _isModified = true;
            });
          }),
          _buildCheckboxListTile('Онкология', _medicalData.hasCancer, (value) {
            setState(() {
              _medicalData = _medicalData.copyWith(hasCancer: value);
              _isModified = true;
            });
          }),

          const SizedBox(height: 16),

          // Другие заболевания
          TextField(
            controller: _otherDiseasesController,
            decoration: const InputDecoration(
              labelText: 'Другие заболевания',
              hintText: 'Укажите другие заболевания, если есть',
            ),
            maxLines: 3,
            onChanged: (_) => _isModified = true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxListTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _disabilityToText(String disability) {
    switch (disability) {
      case 'hearing': return 'По слуху';
      case 'vision': return 'По зрению';
      case 'speech': return 'По речи';
      case 'other': return 'Другое';
      default: return disability;
    }
  }

  Future<void> _saveMedicalData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final uid = widget.userId ?? currentUserId;

    if (uid == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Обновляем данные из полей ввода
      final updatedData = _medicalData.copyWith(
        weight: double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0,
        otherDiseases: _otherDiseasesController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('metadata')
          .doc('medical_data')
          .set(updatedData.toJson());

      setState(() {
        _medicalData = updatedData;
        _isModified = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Медицинские данные сохранены')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}