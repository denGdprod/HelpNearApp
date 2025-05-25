import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'request_detail_screen.dart'; // Экран с деталями заявки

class UserRequestsScreen extends StatelessWidget {
  const UserRequestsScreen({super.key});

  String _translateStatus(String? status) {
    const translations = {
      'open': 'Открыт',
      'in_progress': 'В процессе',
      'closed': 'Закрыт',
    };
    return translations[status] ?? 'Неизвестно';
  }

  Color _getStatusColor(String? status) {
    const colors = {
      'open': Colors.green,
      'in_progress': Colors.orange,
      'closed': Colors.red,
    };
    return colors[status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final DateFormat formatter = DateFormat('HH:mm dd.MM.yyyy');

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Мои заявки')),
        body: const Center(child: Text('Пожалуйста, войдите в аккаунт')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заявки')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('help_requests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки заявок: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Заявок пока нет'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;

              final description = data['description'] ?? '';
              final shortenedDescription = description.length > 25
                  ? '${description.substring(0, 25)}...'
                  : description;

              final createdAtTimestamp = data['createdAt'];
              final createdAt = createdAtTimestamp != null
                  ? (createdAtTimestamp as Timestamp).toDate()
                  : DateTime.now();
              final address = data['incident_address'] ?? 'Адрес не указан';
              final status = data['status'] as String?;

              return ListTile(
                title: Text('$shortenedDescription — $address'),
                subtitle: Row(
                  children: [
                    Text('Создано: ${formatter.format(createdAt.toLocal())}'),
                    const SizedBox(width: 16),
                    const Text('Статус: '),
                    Text(
                      _translateStatus(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(requestData: data),
                    ),
                  );
                },
              );
            }
          );
        },
      ),
    );
  }
}
