import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RequestDetailScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestDetailScreen({super.key, required this.requestData});

  String _translateIncidentType(String? type) {
    const translations = {
      'medical': 'Проблемы со здоровьем',
      'fire': 'Пожар или запах гари',
      'accident': 'Дорожно-транспортное происшествие',
      'crime': 'Подозрительное поведение или конфликт',
      'locked_out': 'Заклинило дверь / нет доступа в жильё',
      'home_emergency': 'Протечка, затопление или авария в доме',
      'electricity': 'Проблемы с электричеством',
      'other': 'Другое происшествие',
    };
    return translations[type] ?? 'Неизвестно';
  }
  String _translateStatus(String? status) {
    const translations = {
      'open': 'Открыт',
      'in_progress': 'В процессе',
      'closed': 'Закрыт',
    };
    return translations[status] ?? 'Неизвестно';
  }

  IconData _iconForIncidentType(String? type) {
    switch (type) {
      case 'medical':
        return Icons.medical_services;
      case 'fire':
        return Icons.local_fire_department;
      case 'accident':
        return Icons.car_crash;
      case 'crime':
        return Icons.report_problem;
      case 'locked_out':
        return Icons.lock;
      case 'home_emergency':
        return Icons.home_repair_service;
      case 'electricity':
        return Icons.electrical_services;
      case 'other':
      default:
        return Icons.help_outline;
    }
  }

  Color _priorityColor(int priority) {
    if (priority <= 3) return Colors.green;
    if (priority <= 7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInfoRow(IconData icon, String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: Colors.blueGrey),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = requestData['id'] ?? 'Неизвестен';
    final incidentTypeKey = requestData['incident_type'] as String?;
    final incidentType = _translateIncidentType(incidentTypeKey);

    final address = requestData['incident_address'] ?? 'Адрес не указан';
    final description = requestData['description'] ?? 'Описание отсутствует';
    final priorityDouble = requestData['priority'] ?? 0.0;
    final priority = (priorityDouble * 10).round();

    final createdAtTimestamp = requestData['createdAt'];
    final createdAt = createdAtTimestamp != null
        ? (createdAtTimestamp as Timestamp).toDate()
        : DateTime.now();

    final formatter = DateFormat('HH:mm dd.MM.yyyy');
    final createdAtStr = formatter.format(createdAt.toLocal());

    final latitude = requestData['latitude']?.toStringAsFixed(6) ?? '0.000000';
    final longitude = requestData['longitude']?.toStringAsFixed(6) ?? '0.000000';

    final hasInjured = requestData['has_injured'] ?? false;
    final isRequesterVictim = requestData['is_requester_victim'] ?? false;

    final status = requestData['status'] ?? 'Неизвестно';

    Color statusColor;
    switch (status) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      case 'closed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Определяем кто нуждается в помощи (взаимоисключающие)
    String helpNeededText;
    if (isRequesterVictim) {
      helpNeededText = 'Мне';
    } else if (hasInjured) {
      helpNeededText = 'Другому';
    } else {
      helpNeededText = 'Не указано';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Детали заявки')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Код заявки — заголовок
            Text(
              'Номер обращения: \n$id',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Тип происшествия — иконка и текст, компактно
            Row(
              children: [
                Icon(_iconForIncidentType(incidentTypeKey),
                    size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  incidentType,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Адрес
            _buildInfoRow(Icons.location_on, 'Адрес:', Text(address)),

            // Координаты
            _buildInfoRow(Icons.map, 'Координаты:', Text('$latitude, $longitude')),

            // Приоритет с цветом и цифрой
            _buildInfoRow(
              Icons.priority_high,
              'Приоритет:',
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _priorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$priority / 10'),
                ],
              ),
            ),

            // Помощь нужна кому
            _buildInfoRow(Icons.volunteer_activism, 'Помощь нужна:', Text(helpNeededText)),
            
            // Описание — большим блоком с рамкой
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Описание:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade400),
                        bottom: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),  // отступы сверху и снизу
                      child: Text(description, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            // Статус
            _buildInfoRow(
              Icons.info_outline,
              'Статус:',
              Text(
                _translateStatus(status),
                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
              ),
            ),

            // Дата создания
            _buildInfoRow(Icons.calendar_today, 'Создано:', Text(createdAtStr)),
          ],
        ),
      ),
    );
  }
}
